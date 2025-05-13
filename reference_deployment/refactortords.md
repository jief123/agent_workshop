# Pet Store Application: Migration from SQLite to Amazon RDS

## Overview

This document outlines the implementation plan for migrating the Pet Store application from using local SQLite databases to a shared Amazon RDS PostgreSQL instance. This migration will resolve the data consistency issues identified in the deployment tests, where each pod was using its own isolated SQLite database.

## Current Issues

- Each pod maintains its own SQLite database file
- Data created in one pod is not visible in other pods
- Updates to data in one pod don't propagate to others
- No single source of truth for application data
- Poor scalability with stateful pods

## Migration Goals

- Establish a single, shared database for all application instances
- Ensure data consistency across all pods
- Improve application scalability
- Maintain high availability
- Implement proper database security

## Implementation Plan

### Phase 1: Provision Amazon RDS PostgreSQL Instance

1. **Create a DB Subnet Group**
   ```bash
   aws rds create-db-subnet-group \
     --db-subnet-group-name petstore-subnet-group \
     --db-subnet-group-description "Subnet group for Pet Store RDS" \
     --subnet-ids subnet-id1 subnet-id2 subnet-id3
   ```

2. **Create Security Group for RDS**
   ```bash
   aws ec2 create-security-group \
     --group-name petstore-rds-sg \
     --description "Security group for Pet Store RDS" \
     --vpc-id vpc-id
   
   # Add inbound rule to allow PostgreSQL traffic from EKS cluster
   aws ec2 authorize-security-group-ingress \
     --group-id sg-rdsgroup \
     --protocol tcp \
     --port 5432 \
     --source-group sg-eksgroup
   ```

3. **Create RDS PostgreSQL Instance**
   ```bash
   aws rds create-db-instance \
     --db-instance-identifier petstore-db \
     --db-instance-class db.t3.micro \
     --engine postgres \
     --engine-version 13.7 \
     --master-username petstore \
     --master-user-password <secure-password> \
     --allocated-storage 20 \
     --storage-type gp2 \
     --db-subnet-group-name petstore-subnet-group \
     --vpc-security-group-ids sg-rdsgroup \
     --db-name petstore \
     --backup-retention-period 7 \
     --multi-az false \
     --publicly-accessible false \
     --tags Key=Environment,Value=Production
   ```

### Phase 2: Update Kubernetes Configuration

1. **Update the Secret with RDS Connection String**
   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: db-credentials
     namespace: petstore
   type: Opaque
   stringData:
     DATABASE_URL: "postgresql://petstore:<secure-password>@petstore-db.xxxxxxxx.region.rds.amazonaws.com:5432/petstore"
   ```

2. **Apply the Updated Secret**
   ```bash
   kubectl apply -f deployment/kubernetes/secret.yaml
   ```

### Phase 3: Data Migration

1. **Create a Data Migration Script**
   ```python
   #!/usr/bin/env python3
   """
   Script to migrate data from SQLite to PostgreSQL
   """
   import os
   import sys
   import sqlite3
   import psycopg2
   from psycopg2.extras import execute_values
   
   # SQLite database file
   SQLITE_DB = "petstore.db"
   
   # PostgreSQL connection string
   PG_CONN_STRING = os.environ.get("DATABASE_URL")
   
   def migrate_data():
       """Migrate data from SQLite to PostgreSQL"""
       print("Starting data migration from SQLite to PostgreSQL...")
       
       # Connect to SQLite
       sqlite_conn = sqlite3.connect(SQLITE_DB)
       sqlite_cursor = sqlite_conn.cursor()
       
       # Get all pets from SQLite
       sqlite_cursor.execute("SELECT id, name, species, breed, age, price, status FROM pets")
       pets = sqlite_cursor.fetchall()
       print(f"Found {len(pets)} pets in SQLite database")
       
       # Connect to PostgreSQL
       pg_conn = psycopg2.connect(PG_CONN_STRING)
       pg_cursor = pg_conn.cursor()
       
       # Create table if it doesn't exist
       pg_cursor.execute("""
       CREATE TABLE IF NOT EXISTS pets (
           id SERIAL PRIMARY KEY,
           name VARCHAR(50) NOT NULL,
           species VARCHAR(50) NOT NULL,
           breed VARCHAR(50),
           age FLOAT,
           price FLOAT NOT NULL,
           status VARCHAR(20) DEFAULT 'available'
       )
       """)
       
       # Insert data into PostgreSQL
       if pets:
           execute_values(
               pg_cursor,
               "INSERT INTO pets (id, name, species, breed, age, price, status) VALUES %s ON CONFLICT (id) DO NOTHING",
               pets
           )
           print(f"Migrated {len(pets)} pets to PostgreSQL")
       
       # Commit changes
       pg_conn.commit()
       
       # Close connections
       sqlite_cursor.close()
       sqlite_conn.close()
       pg_cursor.close()
       pg_conn.close()
       
       print("Migration completed successfully")
   
   if __name__ == "__main__":
       if not PG_CONN_STRING:
           print("Error: DATABASE_URL environment variable not set")
           sys.exit(1)
       
       migrate_data()
   ```

2. **Run the Migration Script**
   ```bash
   # Create a temporary pod with both SQLite and PostgreSQL access
   kubectl run migration-pod --image=python:3.9 --restart=Never -n petstore \
     --env="DATABASE_URL=postgresql://petstore:<secure-password>@petstore-db.xxxxxxxx.region.rds.amazonaws.com:5432/petstore" \
     -- sleep infinity
   
   # Copy SQLite database and migration script to the pod
   kubectl cp petstore.db migration-pod:/petstore.db -n petstore
   kubectl cp migrate.py migration-pod:/migrate.py -n petstore
   
   # Install required packages
   kubectl exec migration-pod -n petstore -- pip install psycopg2-binary
   
   # Run migration script
   kubectl exec migration-pod -n petstore -- python migrate.py
   
   # Clean up
   kubectl delete pod migration-pod -n petstore
   ```

### Phase 4: Deploy and Verify

1. **Restart the Deployment to Use RDS**
   ```bash
   kubectl rollout restart deployment petstore -n petstore
   ```

2. **Verify Database Connectivity**
   ```bash
   # Check pod logs for database connection
   kubectl logs -l app=petstore -n petstore
   
   # Check health endpoint
   kubectl port-forward svc/petstore 8080:80 -n petstore
   curl http://localhost:8080/api/v1/health/details
   ```

3. **Test Data Consistency**
   ```bash
   # Run the data consistency test again
   ./deployment/tests/test_existing_deployment_with_consistency.sh
   ```

### Phase 5: Monitoring and Maintenance

1. **Set Up CloudWatch Alarms for RDS**
   ```bash
   aws cloudwatch put-metric-alarm \
     --alarm-name petstore-db-cpu-high \
     --alarm-description "Alarm when CPU exceeds 80%" \
     --metric-name CPUUtilization \
     --namespace AWS/RDS \
     --statistic Average \
     --period 300 \
     --threshold 80 \
     --comparison-operator GreaterThanThreshold \
     --dimensions Name=DBInstanceIdentifier,Value=petstore-db \
     --evaluation-periods 2 \
     --alarm-actions arn:aws:sns:region:account-id:topic-name
   ```

2. **Configure Automated Backups**
   ```bash
   aws rds modify-db-instance \
     --db-instance-identifier petstore-db \
     --backup-retention-period 7 \
     --preferred-backup-window "03:00-04:00" \
     --apply-immediately
   ```

## Security Considerations

1. **Use AWS Secrets Manager for Database Credentials**
   - Store database credentials in AWS Secrets Manager
   - Update the application to retrieve credentials from Secrets Manager
   - Rotate credentials regularly

2. **Network Security**
   - Ensure RDS is in a private subnet
   - Configure security groups to allow only necessary traffic
   - Use VPC endpoints for additional security

3. **Encryption**
   - Enable encryption at rest for RDS
   - Use SSL/TLS for database connections

## Cost Considerations

1. **RDS Instance Sizing**
   - Start with db.t3.micro for development/testing
   - Monitor usage and adjust as needed
   - Consider reserved instances for production workloads

2. **Storage Allocation**
   - Start with 20GB GP2 storage
   - Enable storage autoscaling with a maximum limit

3. **Multi-AZ Deployment**
   - Consider enabling Multi-AZ for production environments
   - Adds cost but improves availability

## Rollback Plan

1. **If Migration Fails**
   - Revert the secret.yaml to use SQLite
   - Restart the deployment
   - Investigate and fix issues before attempting migration again

2. **If Performance Issues Occur**
   - Check RDS performance insights
   - Optimize database queries
   - Consider scaling up RDS instance if needed

## Conclusion

Migrating from SQLite to Amazon RDS PostgreSQL will resolve the data consistency issues in the Pet Store application. The application code already supports PostgreSQL, so the migration primarily involves infrastructure changes and data transfer. This change will improve application reliability, scalability, and maintainability.

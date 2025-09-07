# Production Deployment Guide

## Overview
This guide covers the essential steps and best practices for deploying the Task App to production.

## Prerequisites
- Domain name configured with DNS
- SSL certificate (Let's Encrypt recommended)
- Production Supabase project
- Production Stripe account
- CI/CD pipeline (GitHub Actions recommended)

## Environment Setup

### 1. Supabase Production Project
```bash
# Create production project
supabase projects create your-app-production

# Link to production project
supabase link --project-ref your-production-ref

# Deploy database migrations
supabase db push

# Deploy Edge Functions
supabase functions deploy
```

### 2. Production Secrets Management
```bash
# Set production secrets (never commit these!)
supabase secrets set STRIPE_SECRET_KEY=sk_live_your_production_key
supabase secrets set STRIPE_PRICE_ID=price_your_production_price
supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_your_production_webhook
supabase secrets set OPENAI_API_KEY=your_production_openai_key

# Verify only necessary secrets are set
supabase secrets list
```

### 3. Frontend Environment Variables
```bash
# .env.production
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_production_anon_key
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_live_your_production_key
```

## Security Best Practices

### 1. Secret Management
- ✅ **Use environment-specific secrets**
- ✅ **Never commit secrets to version control**
- ✅ **Rotate secrets regularly**
- ❌ **Never use service role keys in client-side code**
- ❌ **Don't store database URLs in Edge Functions**

### 2. Database Security
```sql
-- Enable Row Level Security on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- Review and test all RLS policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE schemaname = 'public';
```

### 3. CORS Configuration
```toml
# supabase/config.toml
[api]
enabled = true
port = 54321
schemas = ["public", "graphql_public"]
extra_search_path = ["public", "extensions"]
max_rows = 1000

[cors]
origins = ["https://yourdomain.com", "https://www.yourdomain.com"]
```

## CI/CD Pipeline

### GitHub Actions Example
```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run tests
        run: npm test
        
      - name: Build application
        run: npm run build
        
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v20
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.ORG_ID }}
          vercel-project-id: ${{ secrets.PROJECT_ID }}
          vercel-args: '--prod'
```

## Monitoring and Logging

### 1. Supabase Monitoring
- Enable database metrics
- Set up log retention policies
- Configure alerting for errors

### 2. Application Monitoring
```javascript
// Add error tracking (e.g., Sentry)
import * as Sentry from "@sentry/nextjs";

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
});
```

### 3. Stripe Webhook Monitoring
```typescript
// In stripe-webhook Edge Function
console.log(`Webhook received: ${event.type}`);
console.log(`Processing for customer: ${customer_id}`);
```

## Performance Optimization

### 1. Database Optimization
```sql
-- Add indexes for frequently queried columns
CREATE INDEX idx_profiles_user_id ON profiles(user_id);
CREATE INDEX idx_tasks_user_id ON tasks(user_id);
CREATE INDEX idx_tasks_created_at ON tasks(created_at);
```

### 2. Edge Function Optimization
- Use connection pooling
- Implement proper error handling
- Add request timeouts
- Cache frequently accessed data

### 3. Frontend Optimization
- Enable Next.js production optimizations
- Use CDN for static assets
- Implement proper caching headers
- Optimize images and fonts

## Backup and Recovery

### 1. Database Backups
```bash
# Automated daily backups (configure in Supabase dashboard)
# Point-in-time recovery available for 7 days

# Manual backup
supabase db dump --file backup.sql
```

### 2. Disaster Recovery Plan
1. **RTO (Recovery Time Objective)**: < 4 hours
2. **RPO (Recovery Point Objective)**: < 1 hour
3. **Backup verification**: Weekly restore tests
4. **Documentation**: Keep runbooks updated

## Scaling Considerations

### 1. Database Scaling
- Monitor connection pool usage
- Consider read replicas for heavy read workloads
- Implement database connection pooling

### 2. Edge Function Scaling
- Functions auto-scale with Supabase
- Monitor execution time and memory usage
- Implement proper error handling and retries

### 3. Frontend Scaling
- Use CDN (Vercel Edge Network)
- Implement proper caching strategies
- Consider server-side rendering for SEO

## Security Checklist

- [ ] All secrets stored securely (not in code)
- [ ] Row Level Security enabled on all tables
- [ ] CORS properly configured
- [ ] HTTPS enforced everywhere
- [ ] Regular security audits scheduled
- [ ] Dependency updates automated
- [ ] Error messages don't leak sensitive data
- [ ] Rate limiting implemented
- [ ] Input validation on all endpoints
- [ ] SQL injection prevention verified

## Post-Deployment Verification

### 1. Functional Testing
```bash
# Test critical user flows
- User registration
- Email verification
- Password reset
- Subscription creation
- Task management
- File uploads
```

### 2. Performance Testing
- Page load times < 3 seconds
- API response times < 500ms
- Database query performance
- Edge Function cold start times

### 3. Security Testing
- SSL certificate validation
- CORS policy verification
- Authentication flow testing
- Authorization boundary testing

## Maintenance

### 1. Regular Updates
- Weekly dependency updates
- Monthly security patches
- Quarterly feature releases

### 2. Monitoring
- Daily error log reviews
- Weekly performance reports
- Monthly security audits

### 3. Backup Verification
- Weekly backup restoration tests
- Monthly disaster recovery drills
- Quarterly business continuity reviews

## Support and Documentation

### 1. Runbooks
- Incident response procedures
- Deployment rollback procedures
- Database maintenance procedures

### 2. Contact Information
- On-call engineer rotation
- Escalation procedures
- Vendor support contacts

### 3. Documentation Updates
- Keep deployment guide current
- Update architecture diagrams
- Maintain API documentation

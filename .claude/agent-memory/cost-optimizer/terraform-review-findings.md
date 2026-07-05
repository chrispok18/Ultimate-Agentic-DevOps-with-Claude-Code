---
name: portfolio-cloudfront-cost-analysis
description: Cost optimization findings for personal portfolio S3+CloudFront infrastructure
metadata:
  type: project
---

## Infrastructure Summary
- **Type**: Static HTML/CSS portfolio site
- **Services**: S3 bucket (origin) + CloudFront CDN
- **Scale**: Personal portfolio (low traffic expected)
- **Deploy method**: GitHub Actions → S3 sync + CloudFront invalidation

## Key Cost-Drivers Identified

### 1. CloudFront Price Class: PriceClass_200 (FIXABLE - Medium Impact)
**Current**: PriceClass_200 covers North America, Europe, Asia, Middle East, Africa, South America, and Australia.  
**Issue**: For a personal portfolio with likely audience concentration in US/EU/Asia, PriceClass_100 would suffice.  
**Savings**: ~35% reduction on CloudFront data transfer costs (scales with traffic volume; estimated $5-15/month for modest portfolio traffic).  
**Fix**: Change line 82 in `terraform/main.tf` from `PriceClass_200` to `PriceClass_100`.

### 2. CloudFront Caching & TTL (ALREADY OPTIMIZED)
**Status**: Using AWS managed "CachingOptimized" policy with 1-year TTL for most static assets.  
**Good**: GitHub Actions workflow correctly invalidates cache on deploy.  
**No action needed**.

### 3. S3 Storage & Lifecycle (ALREADY OPTIMIZED)
**Status**: 
- No versioning enabled (prevents cost creep from old object versions)
- No logging configured (eliminates logging storage costs)
- Standard storage class appropriate for content
- No multipart upload cleanup needed (not a high-volume upload scenario)

**No action needed**.

### 4. Terraform State Backend (PRECAUTION)
**Status**: Currently commented out (local state).  
**When enabled**: Should avoid S3 versioning on state bucket. State files are small (~1-10MB), so cost is minimal, but versioning would accumulate old versions.  
**Prevention**: When backend is uncommented, ensure no versioning is enabled on the state bucket, or add lifecycle rules if it is.

## Risk Areas (Not Cost Issues, But Worth Noting)
- No S3 bucket logging means no access logs to CloudFront origin requests; this is a tradeoff (saves cost but reduces debuggability)
- Price Class cannot be changed on existing distributions without recreation; plan accordingly

## Estimated Monthly Cost (for reference)
- S3 storage: ~$0.10-0.50 (100MB-1GB of static files)
- CloudFront data transfer: ~$2-20 depending on traffic (at PriceClass_200 rates)
- CloudFront requests: ~$0.10-1 depending on traffic
- **Total**: ~$2.50-21.50/month at current config

With PriceClass_100 change: ~$2.50-19.50/month (saves ~$2-2.50/month at high-traffic scenario)

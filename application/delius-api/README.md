# Delius-API

The [delius-api](https://github.com/ministryofjustice/hmpps-delius-api) provides granular access to data held within the National Delius application, enabling updates to be performed by other Digital services in a controlled manner.  

This module defines a load-balanced ECS service running the public docker image [hmpps/delius-api](https://gallery.ecr.aws/s8p2y7q3/delius-api),
which is configured with access to the Delius database.

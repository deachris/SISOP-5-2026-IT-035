#!/bin/bash

TIMESTAMP=$(date +%d%m%Y-%H%M%S)
BACKUP="osboot/farewell_backup_[${TIMESTAMP}].zip"

zip "$BACKUP" osboot/bzImage osboot/single.gz osboot/multi.gz osboot/farewell.iso

rm osboot/bzImage osboot/single.gz osboot/multi.gz osboot/farewell.iso

using './stg.bicep'

param storageAccountNamePrefix = 'stg'

param storageSkuType = 'Standard_LRS'

param storageKindType = 'StorageV2'

param storageTlsVersion = 'TLS1_2'

param accessTierType = 'Hot'

param publicNetworkAccess = 'Disabled'

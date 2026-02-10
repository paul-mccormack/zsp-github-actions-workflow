//
// User Defined Types
//

@description('User defined type to restrict Minimum TLS version to acceptable values')
type minimumTlsVersionType = 'TLS1_2' | 'TLS1_3'

//
// Parameters
//

@description('Resource location from resource group')
param location string = resourceGroup().location

@description('Storage Account name prefix. Name will be suffixed with a unique identifier to ensure global uniqueness.')
@minLength(3)
@maxLength(11)
param storageAccountNamePrefix string

@description('Storage Account SKU using resourceInput function')
param storageSkuType resourceInput<'Microsoft.Storage/storageAccounts@2025-01-01'>.sku.name

@description('Storage Account kind using resourceInput function')
param storageKindType resourceInput<'Microsoft.Storage/storageAccounts@2025-01-01'>.kind

@description('Storage Account access tier using resouceInput function')
param accessTierType resourceInput<'Microsoft.Storage/storageAccounts@2025-01-01'>.properties.accessTier

@description('Storage account public network access using resourceInput function')
param publicNetworkAccess resourceInput<'Microsoft.Storage/storageAccounts@2025-01-01'>.properties.publicNetworkAccess

@description('Storage account tls version from User Defined Type')
param storageTlsVersion minimumTlsVersionType

//
// Variables
//

// Generate unique storage account name (max 24 chars, lowercase, valid for Azure)
var uniqueStorageName = toLower('${storageAccountNamePrefix}${uniqueString(resourceGroup().id)}')
var storageName = take(uniqueStorageName, 24)

//
// Resources
//

@description('Deploy storage account')
resource stg 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: storageName
  location: location
  sku: {
    name: storageSkuType
  }
  kind: storageKindType
  properties: {
    minimumTlsVersion: storageTlsVersion
    accessTier: accessTierType
    publicNetworkAccess: publicNetworkAccess
  }
}

//
// Outputs
//

@description('Storage Account name output')
output storageAccountName string = stg.name

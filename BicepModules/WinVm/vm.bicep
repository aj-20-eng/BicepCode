param storageAccountName string = '8789abc45'
param location string = resourceGroup().location
param adminUsername string = 'youradminuser'
param admin string = 'Pass123456789' // Replace with your actual password

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: '${resourceGroup().name}${storageAccountName}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}
resource vm 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: 'YourVMName'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_DS1_v2'
    }
    osProfile: {
      computerName: 'YourVMName'
      adminUsername: adminUsername
      adminPassword: admin
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', 'YourNICName')
        }
      ]
    }
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: 'YourNICName'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', 'YourVNETName', 'YourSubnetName')
          }
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: 'YourVNETName'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: 'YourSubnetName'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

output vmId string = vm.id
output storageAccountId string = storageAccount.id
output nicId string = nic.id
output vnetId string = vnet.id

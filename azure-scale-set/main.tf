
resource "azurerm_resource_group" "scale-set" {
  name     = "${var.environment}-resources"
  location = var.location
}

resource "azurerm_virtual_network" "scale-set" {
  name                = "${var.environment}-network"
  resource_group_name = azurerm_resource_group.scale-set.name
  location            = azurerm_resource_group.scale-set.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.scale-set.name
  virtual_network_name = azurerm_virtual_network.scale-set.name
  address_prefixes       = ["10.0.2.0/24"]
}

resource "azurerm_linux_virtual_machine_scale_set" "scale-set" {
  name                = "${var.environment}-vmss"
  resource_group_name = azurerm_resource_group.scale-set.name
  location            = azurerm_resource_group.scale-set.location
  sku                 = "Standard_F2"
  instances           = 1
  admin_username      = "adminuser"

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "example"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.internal.id
    }
  }
}

resource "azurerm_monitor_autoscale_setting" "example" {
  name                = "myAutoscaleSetting"
  resource_group_name = azurerm_resource_group.scale-set.name
  location            = azurerm_resource_group.scale-set.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.scale-set.id

  profile {
    name = "InHours"

    capacity {
      default = 1
      minimum = 1
      maximum = 3 
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.scale-set.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.scale-set.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    recurrence {
      timezone  = var.time_zone
      days      = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
      hours     = [var.in_hour]
      minutes   = [var.in_minute]
    }
  }

  profile {
    name = "OutOfHours"

    capacity {
      default = 0
      minimum = 0
      maximum = 0
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.scale-set.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }


    recurrence {
      timezone  = var.time_zone
      days      = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
      hours     = [var.out_hour]
      minutes   = [var.out_minute]
    }

  }
}

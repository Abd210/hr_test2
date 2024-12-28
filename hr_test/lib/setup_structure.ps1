# Directories to create
$directories = @(
    "lib\models",
    "lib\providers",
    "lib\screens",
    "lib\widgets",
    "lib\utils"
)

# Create directories
foreach ($dir in $directories) {
    New-Item -Path $dir -ItemType Directory -Force
}

# Files to create with their paths
$files = @(
    "lib\models\user.dart",
    "lib\models\role.dart",
    "lib\models\permission.dart",
    "lib\models\organization.dart",
    "lib\models\test.dart",
    "lib\providers\auth_provider.dart",
    "lib\providers\admin_provider.dart",
    "lib\screens\login_screen.dart",
    "lib\screens\admin_screen.dart",
    "lib\widgets\custom_button.dart",
    "lib\widgets\custom_text_field.dart",
    "lib\utils\constants.dart"
)

# Create files
foreach ($file in $files) {
    New-Item -Path $file -ItemType File -Force
}

Write-Output "Project structure setup complete."

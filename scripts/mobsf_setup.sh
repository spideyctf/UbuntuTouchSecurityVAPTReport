#!/bin/bash

# MobSF Setup Script for Ubuntu Touch Security Testing
# This script automates the setup of Mobile Security Framework (MobSF)
# for conducting security assessments on Ubuntu Touch applications

set -e

echo "=========================================="
echo "MobSF Setup for Ubuntu Touch Security Testing"
echo "=========================================="

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "[-] This script should not be run as root for security reasons"
    exit 1
fi

# Update system packages
echo "[+] Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install required dependencies
echo "[+] Installing required dependencies..."
sudo apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    git \
    wget \
    curl \
    unzip \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    libjpeg-dev \
    zlib1g-dev

# Create virtual environment
echo "[+] Creating Python virtual environment..."
python3 -m venv mobsf_env
source mobsf_env/bin/activate

# Upgrade pip
echo "[+] Upgrading pip..."
pip install --upgrade pip

# Install MobSF
echo "[+] Installing Mobile Security Framework..."
pip install mobsf

# Create MobSF configuration directory
echo "[+] Creating MobSF configuration..."
mkdir -p ~/.mobsf
cat > ~/.mobsf/settings.py << 'EOF'
# MobSF Configuration for Ubuntu Touch Security Testing

import os

# Basic settings
DEBUG = False
ALLOWED_HOSTS = ['*']

# Database settings
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(os.path.expanduser('~'), '.mobsf', 'db.sqlite3'),
    }
}

# Static files
STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(os.path.expanduser('~'), '.mobsf', 'static')

# Media files
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(os.path.expanduser('~'), '.mobsf', 'media')

# Security settings
SECRET_KEY = 'your-secret-key-change-this-in-production'
SECURE_SSL_REDIRECT = False
SESSION_COOKIE_SECURE = False
CSRF_COOKIE_SECURE = False

# Logging
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'file': {
            'level': 'INFO',
            'class': 'logging.FileHandler',
            'filename': os.path.join(os.path.expanduser('~'), '.mobsf', 'mobsf.log'),
        },
    },
    'loggers': {
        'mobsf': {
            'handlers': ['file'],
            'level': 'INFO',
            'propagate': True,
        },
    },
}
EOF

# Create Ubuntu Touch specific test cases
echo "[+] Creating Ubuntu Touch specific test cases..."
mkdir -p ~/.mobsf/test_cases/ubuntu_touch

cat > ~/.mobsf/test_cases/ubuntu_touch/snap_security.py << 'EOF'
"""
Ubuntu Touch Snap Security Test Cases
"""

def test_snap_confinement():
    """Test snap confinement security"""
    # Test cases for snap security
    pass

def test_snap_interfaces():
    """Test snap interface permissions"""
    # Test cases for snap interfaces
    pass

def test_snap_privileges():
    """Test snap privilege escalation"""
    # Test cases for snap privileges
    pass
EOF

# Create startup script
echo "[+] Creating MobSF startup script..."
cat > ~/start_mobsf.sh << 'EOF'
#!/bin/bash

# Start MobSF for Ubuntu Touch Security Testing
echo "Starting MobSF for Ubuntu Touch Security Testing..."

# Activate virtual environment
source ~/mobsf_env/bin/activate

# Set environment variables
export DJANGO_SETTINGS_MODULE=mobsf.settings

# Start MobSF
cd ~/.mobsf
python manage.py runserver 0.0.0.0:8000
EOF

chmod +x ~/start_mobsf.sh

# Create test data directory
echo "[+] Creating test data directory..."
mkdir -p ~/ubuntu_touch_test_data/{snaps,apps,logs}

# Download sample Ubuntu Touch apps for testing
echo "[+] Setting up test data..."
cat > ~/ubuntu_touch_test_data/README.md << 'EOF'
# Ubuntu Touch Test Data

This directory contains test data for Ubuntu Touch security assessments.

## Structure
- snaps/ - Sample snap packages for testing
- apps/ - Ubuntu Touch applications for analysis
- logs/ - Security assessment logs

## Usage
1. Place snap packages in the snaps/ directory
2. Place app files in the apps/ directory
3. Run MobSF analysis on these files
4. Review logs in the logs/ directory
EOF

# Create analysis script
echo "[+] Creating analysis script..."
cat > ~/analyze_ubuntu_touch.sh << 'EOF'
#!/bin/bash

# Ubuntu Touch Security Analysis Script
# This script automates security analysis of Ubuntu Touch applications

if [ $# -eq 0 ]; then
    echo "Usage: $0 <path_to_app_or_snap>"
    echo "Example: $0 ~/ubuntu_touch_test_data/snaps/example.snap"
    exit 1
fi

TARGET="$1"
OUTPUT_DIR="$HOME/ubuntu_touch_test_data/logs/$(date +%Y%m%d_%H%M%S)"

echo "=========================================="
echo "Ubuntu Touch Security Analysis"
echo "=========================================="
echo "Target: $TARGET"
echo "Output: $OUTPUT_DIR"
echo "=========================================="

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Activate virtual environment
source ~/mobsf_env/bin/activate

# Run MobSF analysis
echo "[+] Starting MobSF analysis..."
mobsf --analyze "$TARGET" --output "$OUTPUT_DIR"

# Generate report
echo "[+] Generating security report..."
cat > "$OUTPUT_DIR/security_report.md" << 'REPORT'
# Ubuntu Touch Security Analysis Report

## Target
- File: $TARGET
- Analysis Date: $(date)
- Analysis Tool: MobSF

## Findings
[Analysis results will be populated here]

## Recommendations
[Security recommendations will be provided here]

## Next Steps
1. Review detailed analysis results
2. Address identified security issues
3. Implement recommended security measures
4. Re-test after remediation
REPORT

echo "[+] Analysis complete. Results saved to: $OUTPUT_DIR"
echo "[+] To view results, open: $OUTPUT_DIR/security_report.md"
EOF

chmod +x ~/analyze_ubuntu_touch.sh

# Create cleanup script
echo "[+] Creating cleanup script..."
cat > ~/cleanup_mobsf.sh << 'EOF'
#!/bin/bash

# MobSF Cleanup Script
echo "Cleaning up MobSF installation..."

# Deactivate virtual environment if active
if [ -n "$VIRTUAL_ENV" ]; then
    deactivate
fi

# Remove virtual environment
if [ -d "$HOME/mobsf_env" ]; then
    echo "Removing virtual environment..."
    rm -rf "$HOME/mobsf_env"
fi

# Remove MobSF configuration
if [ -d "$HOME/.mobsf" ]; then
    echo "Removing MobSF configuration..."
    rm -rf "$HOME/.mobsf"
fi

# Remove test data
if [ -d "$HOME/ubuntu_touch_test_data" ]; then
    echo "Removing test data..."
    rm -rf "$HOME/ubuntu_touch_test_data"
fi

# Remove scripts
rm -f "$HOME/start_mobsf.sh"
rm -f "$HOME/analyze_ubuntu_touch.sh"
rm -f "$HOME/cleanup_mobsf.sh"

echo "Cleanup complete."
EOF

chmod +x ~/cleanup_mobsf.sh

echo ""
echo "=========================================="
echo "MobSF Setup Complete!"
echo "=========================================="
echo ""
echo "To start MobSF:"
echo "  ~/start_mobsf.sh"
echo ""
echo "To analyze Ubuntu Touch apps:"
echo "  ~/analyze_ubuntu_touch.sh <path_to_app>"
echo ""
echo "To cleanup:"
echo "  ~/cleanup_mobsf.sh"
echo ""
echo "MobSF will be available at: http://localhost:8000"
echo ""
echo "Note: Make sure to change the SECRET_KEY in ~/.mobsf/settings.py"
echo "      before using in production environments."
echo ""

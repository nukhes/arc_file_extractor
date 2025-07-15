"""Utility functions for Arc File Extractor."""

import shutil
from pathlib import Path
from typing import List


def check_dependencies() -> List[str]:
    """Check if required external tools are installed.
    
    Returns:
        List of missing dependencies
    """
    required_tools = [
        "unzip", "tar", "gunzip", "bunzip2", "unxz", "7z", "unrar", 
        "zip", "gzip", "bzip2", "xz", "rar"
    ]
    
    missing = []
    for tool in required_tools:
        if not shutil.which(tool):
            missing.append(tool)
    
    return missing


def get_supported_formats() -> dict:
    """Get supported file formats for extraction and compression.
    
    Returns:
        Dictionary with 'extract' and 'compress' keys containing lists of formats
    """
    return {
        "extract": [
            ".zip", ".tar", ".tar.gz", ".tgz", ".tar.bz2", ".tbz", 
            ".tar.xz", ".txz", ".gz", ".bz2", ".xz", ".7z", ".rar"
        ],
        "compress": [
            ".zip", ".tar", ".tar.gz", ".tgz", ".tar.bz2", ".tbz", 
            ".tar.xz", ".txz", ".7z", ".rar"
        ]
    }


def validate_file_path(file_path: str) -> bool:
    """Validate if a file path exists and is readable.
    
    Args:
        file_path: Path to validate
        
    Returns:
        True if valid, False otherwise
    """
    path = Path(file_path)
    return path.exists() and path.is_file()


def get_file_size(file_path: str) -> str:
    """Get human-readable file size.
    
    Args:
        file_path: Path to the file
        
    Returns:
        Human-readable file size string
    """
    try:
        size = Path(file_path).stat().st_size
        for unit in ['B', 'KB', 'MB', 'GB']:
            if size < 1024.0:
                return f"{size:.1f} {unit}"
            size /= 1024.0
        return f"{size:.1f} TB"
    except (OSError, FileNotFoundError):
        return "Unknown"

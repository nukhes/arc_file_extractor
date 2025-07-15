"""Main module for Arc File Extractor."""

import subprocess
from pathlib import Path
from typing import Optional


class ArcFileExtractor:
    """Main class for file extraction and compression operations."""
    
    def __init__(self):
        self.extract_commands = {
            ".zip": ["unzip", "-q"],
            ".tar": ["tar", "-xf"],
            ".tar.gz": ["tar", "-xzf"],
            ".tgz": ["tar", "-xzf"],
            ".tar.bz2": ["tar", "-xjf"],
            ".tbz": ["tar", "-xjf"],
            ".tar.xz": ["tar", "-xJf"],
            ".txz": ["tar", "-xJf"],
            ".gz": ["gunzip"],
            ".bz2": ["bunzip2"],
            ".xz": ["unxz"],
            ".7z": ["7z", "x"],
            ".rar": ["unrar", "x"]
        }
        
        self.compress_commands = {
            ".zip": ["zip", "-r"],
            ".tar": ["tar", "-cf"],
            ".tar.gz": ["tar", "-czf"],
            ".tgz": ["tar", "-czf"],
            ".tar.bz2": ["tar", "-cjf"],
            ".tbz": ["tar", "-cjf"],
            ".tar.xz": ["tar", "-cJf"],
            ".txz": ["tar", "-cJf"],
            ".7z": ["7z", "a"],
            ".rar": ["rar", "a"]
        }
    
    def extract(self, file_path: str) -> int:
        """Extract a file to a directory with the same name.
        
        Args:
            file_path: Path to the file to extract
            
        Returns:
            Exit code (0 for success, 1 for failure)
        """
        if not Path(file_path).exists():
            print(f"[!] File not found: {file_path}")
            return 1
            
        # Get file extension(s)
        file_path_obj = Path(file_path)
        
        # Check for compound extensions first
        for ext in [".tar.gz", ".tar.bz2", ".tar.xz"]:
            if file_path.lower().endswith(ext):
                command = self.extract_commands[ext] + [file_path]
                return self._run_command(command, file_path_obj.stem.replace('.tar', ''))
        
        # Check for simple extensions
        ext = file_path_obj.suffix.lower()
        if ext in self.extract_commands:
            output_dir = file_path_obj.stem
            command = self.extract_commands[ext] + [file_path]
            return self._run_command(command, output_dir)
        
        print(f"[!] Unsupported file format for extraction: {ext}")
        return 1
    
    def compress(self, source_path: str, output_file: Optional[str] = None) -> int:
        """Compress a file or directory.
        
        Args:
            source_path: Path to the file or directory to compress
            output_file: Optional output file path (defaults to source_path.zip)
            
        Returns:
            Exit code (0 for success, 1 for failure)
        """
        if not Path(source_path).exists():
            print(f"[!] Source not found: {source_path}")
            return 1
            
        if output_file is None:
            output_file = f"{source_path}.zip"
            
        # Get file extension(s)
        output_path_obj = Path(output_file)
        
        # Check for compound extensions first
        for ext in [".tar.gz", ".tar.bz2", ".tar.xz"]:
            if output_file.lower().endswith(ext):
                command = self.compress_commands[ext] + [output_file, source_path]
                return self._run_command(command)
        
        # Check for simple extensions
        ext = output_path_obj.suffix.lower()
        if ext in self.compress_commands:
            command = self.compress_commands[ext] + [output_file, source_path]
            return self._run_command(command)
        
        print(f"[!] Unsupported file format for compression: {ext}")
        return 1
    
    def _run_command(self, command: list, output_dir: Optional[str] = None) -> int:
        """Run a command and handle directory creation for extraction.
        
        Args:
            command: Command to run
            output_dir: Directory to create for extraction
            
        Returns:
            Exit code
        """
        try:
            if output_dir:
                # Create output directory for extraction
                Path(output_dir).mkdir(exist_ok=True)
                # Change to output directory for extraction
                result = subprocess.run(command, cwd=output_dir, check=True)
            else:
                result = subprocess.run(command, check=True)
            
            return result.returncode
        except subprocess.CalledProcessError as e:
            print(f"[!] Command failed: {' '.join(command)}")
            print(f"[!] Error: {e}")
            return 1
        except FileNotFoundError:
            print(f"[!] Command not found: {command[0]}")
            print(f"[!] Please install {command[0]} to use this format")
            return 1

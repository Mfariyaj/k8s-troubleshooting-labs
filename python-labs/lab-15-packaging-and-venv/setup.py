# BROKEN setup.py — has issues with package discovery

from setuptools import setup, find_packages

setup(
    name="mytools",
    version="0.1.0",
    description="DevOps utility toolkit",
    author="DevOps Team",
    # BUG: package_dir and packages don't match actual structure
    package_dir={"": "lib"},  # Wrong! Source is in 'src' not 'lib'
    packages=find_packages(where="lib"),  # Wrong directory
    python_requires=">=3.8",
    install_requires=[
        "requests>=2.28.0",
        "pyyaml>=6.0",
    ],
)

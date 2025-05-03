# JAC Management System - User Guide

## Overview
The JAC Management System is a comprehensive web-based application designed for James An College Victoria. This system helps manage various aspects of the college's operations.

![JAC Management System Login Page](docs/images/login-page.png)
*Figure 1: JAC Management System Login Page*

## System Requirements
- Java 11 or higher
- MySQL Database
- Web browser (Chrome, Firefox, Safari recommended)
- Internet connection for Azure Blob Storage features

## Features

### 1. Security and Authentication
- Secure login system using Spring Security
- Role-based access control
- Session management

![User Authentication Flow](docs/images/auth-flow.png)
*Figure 2: Authentication and Authorization Process*

### 2. Document Management
- PDF generation and processing using iText7
- Excel file handling with Apache POI
- File storage using Azure Blob Storage
- Document upload and download capabilities

![Document Management Interface](docs/images/doc-management.png)
*Figure 3: Document Management Dashboard*

![File Upload Process](docs/images/file-upload.png)
*Figure 4: File Upload Interface*

### 3. OMR (Optical Mark Recognition)
- Automated form processing using Aspose OMR
- PDF document processing with PDFBox

![OMR Processing](docs/images/omr-process.png)
*Figure 5: OMR Form Processing Interface*

### 4. Reporting and Analytics
- Chart generation using JFreeChart
- Data visualization capabilities
- Excel report generation

![Analytics Dashboard](docs/images/analytics-dashboard.png)
*Figure 6: Analytics and Reporting Dashboard*

![Report Generation](docs/images/report-generation.png)
*Figure 7: Report Generation Interface*

### 5. Communication
- Email functionality through Spring Mail
- Notification system

![Email Template Management](docs/images/email-templates.png)
*Figure 8: Email Template Configuration*

## Getting Started

### Installation
1. Ensure Java 11 is installed on your system
2. Configure MySQL database according to application properties
3. Deploy the WAR file to a Tomcat server
4. Access the application through your web browser

![Installation Steps](docs/images/installation-steps.png)
*Figure 9: Installation Process Overview*

### Configuration
The following configurations may need to be set up:
- Database connection details
- Azure Blob Storage credentials
- Email server settings
- Application-specific properties

![System Configuration](docs/images/system-config.png)
*Figure 10: System Configuration Interface*

### First-time Setup
1. Log in with administrator credentials
2. Set up initial user accounts and roles
3. Configure system parameters
4. Set up email templates if required

![Initial Setup](docs/images/initial-setup.png)
*Figure 11: First-time Setup Wizard*

## Common Tasks

### Document Management
1. Navigate to the document section
2. Use the upload feature to store new documents
3. Use search and filter options to find existing documents
4. Download or share documents as needed

![Document Upload Flow](docs/images/doc-upload-flow.png)
*Figure 12: Document Upload Process*

### Reporting
1. Access the reporting module
2. Select report type
3. Set parameters and date ranges
4. Generate and export reports

![Report Creation](docs/images/report-creation.png)
*Figure 13: Report Creation Process*

### User Management
1. Access the admin panel
2. Add/modify user accounts
3. Assign roles and permissions
4. Reset passwords if needed

![User Management Panel](docs/images/user-management.png)
*Figure 14: User Management Interface*

## Troubleshooting

### Common Issues
1. **Login Problems**
   - Verify credentials
   - Check if account is locked
   - Contact administrator for password reset

![Login Troubleshooting](docs/images/login-trouble.png)
*Figure 15: Common Login Issues and Solutions*

2. **File Upload Issues**
   - Check file size limits
   - Verify supported file formats
   - Ensure stable internet connection

![Upload Troubleshooting](docs/images/upload-trouble.png)
*Figure 16: File Upload Troubleshooting Guide*

3. **Report Generation Errors**
   - Verify data availability
   - Check date range parameters
   - Ensure proper permissions

![Report Troubleshooting](docs/images/report-trouble.png)
*Figure 17: Report Generation Troubleshooting*

### Support
For technical support:
- Contact system administrator
- Submit support ticket
- Check system documentation

![Support Portal](docs/images/support-portal.png)
*Figure 18: Support Ticket System*

## Security Best Practices
1. Regular password changes
2. Logout after each session
3. Don't share login credentials
4. Use secure network connections

![Security Guidelines](docs/images/security-guidelines.png)
*Figure 19: Security Best Practices Overview*

## Updates and Maintenance
- System updates are managed by IT administrators
- Regular backups are performed
- Maintenance windows will be communicated

![Maintenance Schedule](docs/images/maintenance-schedule.png)
*Figure 20: System Maintenance Calendar*

## Technical Details
- Built with Spring Boot 2.2.8
- Uses MySQL database
- Integrates with Azure cloud services
- Supports JSP with Apache Tiles
- Implements Spring Security

![System Architecture](docs/images/system-architecture.png)
*Figure 21: System Architecture Diagram*

## Legal and Compliance
- Follow data protection guidelines
- Adhere to privacy policies
- Maintain confidentiality of information

![Compliance Dashboard](docs/images/compliance-dashboard.png)
*Figure 22: Compliance Monitoring Dashboard*

---

For additional support or questions, please contact the system administrator.

## Screenshot Instructions for System Administrators

To maintain this documentation:

1. **Taking Screenshots**:
   - Use a high-resolution display (minimum 1920x1080)
   - Set browser zoom to 100%
   - Use browser's built-in screenshot tool or professional screenshot software
   - Capture the entire relevant interface
   - Ensure no sensitive information is visible

2. **Naming Convention**:
   - Save screenshots using the exact names shown in this document
   - Use PNG format for best quality
   - Store in the `docs/images/` directory

3. **Updating Screenshots**:
   - Update screenshots when interface changes occur
   - Maintain consistent image dimensions
   - Add new screenshots as needed for new features
   - Remove obsolete screenshots

4. **Image Requirements**:
   - Format: PNG
   - Resolution: Minimum 1920x1080
   - Maximum file size: 2MB per image
   - Clear and readable text
   - No personal or sensitive information visible 
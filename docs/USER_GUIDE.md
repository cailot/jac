# JAC Management System - User Guide

## Overview
The JAC Management System is a comprehensive web-based application designed for James An College Victoria. This system helps manage various aspects of the college's operations including document management, OMR processing, reporting, and communication.

## System Requirements
- Java 11 or higher
- MySQL Database
- Web browser (Chrome, Firefox, Safari recommended)
- Internet connection for Azure Blob Storage features

## Features

### 1. Security and Authentication
- Secure login system using Spring Security
- Role-based access control
- Session management with 30-minute timeout

### 2. Document Management
- PDF generation and processing using iText7
- Excel file handling with Apache POI
- File storage using Azure Blob Storage
- Document upload and download capabilities
- Maximum file size: 100MB

### 3. OMR (Optical Mark Recognition)
- Automated form processing using Aspose OMR
- PDF document processing with PDFBox
- Template-based recognition system
- Batch processing capabilities

### 4. Reporting and Analytics
- Chart generation using JFreeChart
- Data visualization capabilities
- Excel report generation
- Customizable report parameters

### 5. Communication
- Email integration through Microsoft Office 365 SMTP
- Automated notifications
- Template-based email system
- Multiple sender configurations for different purposes

## Getting Started

### Installation
1. Ensure Java 11 is installed on your system
2. Configure MySQL database according to application properties
3. Deploy the WAR file to Tomcat 9.0 server
4. Access the application through your web browser at port 8080

### Configuration
The following configurations need to be set up:

1. Database Configuration:
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/jac?serverTimezone=Australia/Sydney
spring.datasource.username=your_username
spring.datasource.password=your_password
```

2. Email Configuration:
```properties
spring.mail.host=smtp.office365.com
spring.mail.port=587
spring.mail.username=your_email@domain.com
spring.mail.password=your_password
```

3. Azure Storage Configuration:
```properties
azure.storage.connection=your_azure_storage_connection_string
```

### First-time Setup
1. Log in with administrator credentials
2. Set up initial user accounts and roles
3. Configure system parameters
4. Set up email templates if required

## Common Tasks

### Document Management
1. Navigate to the document section
2. Use the upload feature to store new documents
3. Use search and filter options to find existing documents
4. Download or share documents as needed

### OMR Processing
1. Access the OMR module
2. Upload scanned answer sheets
3. Select appropriate template
4. Process and review results
5. Export or save results

### Reporting
1. Access the reporting module
2. Select report type
3. Set parameters and date ranges
4. Generate and export reports

### User Management
1. Access the admin panel
2. Add/modify user accounts
3. Assign roles and permissions
4. Reset passwords if needed

## Troubleshooting

### Common Issues
1. **Login Problems**
   - Verify credentials
   - Check if account is locked
   - Contact administrator for password reset

2. **File Upload Issues**
   - Check file size (max 100MB)
   - Verify supported file formats
   - Ensure stable internet connection

3. **Report Generation Errors**
   - Verify data availability
   - Check date range parameters
   - Ensure proper permissions

### Support
For technical support:
- Contact system administrator
- Submit support ticket
- Check system documentation

## Security Best Practices
1. Regular password changes
2. Logout after each session
3. Don't share login credentials
4. Use secure network connections

## Updates and Maintenance
- System updates are managed by IT administrators
- Regular backups are performed
- Maintenance windows will be communicated

## Technical Details
- Built with Spring Boot
- Uses MySQL database
- Integrates with Azure cloud services
- Supports JSP with Apache Tiles
- Implements Spring Security

## Legal and Compliance
- Follow data protection guidelines
- Adhere to privacy policies
- Maintain confidentiality of information

---

For additional support or questions, please contact the system administrator. 
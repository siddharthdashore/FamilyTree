-- ============================================================================
-- VanshaSetu (वन्शसेतु) — Multi-Generational Seed Data (5-Layer Hierarchy)
-- Generated: 2026-09-25T19:06:25.160Z
-- ============================================================================

USE `vanshasetu_db`;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE `audit_logs`;
TRUNCATE TABLE `marriages`;
TRUNCATE TABLE `citizen_education`;
TRUNCATE TABLE `duplicate_conflict_logs`;
TRUNCATE TABLE `citizen_documents`;
TRUNCATE TABLE `relationships`;
TRUNCATE TABLE `citizens`;
SET FOREIGN_KEY_CHECKS = 1;

-- ----------------------------------------------------------------------------
-- 1. Insert 5-Layer Citizens
-- ----------------------------------------------------------------------------
INSERT INTO `citizens` (
    `vuid`, `first_name`, `middle_name`, `last_name`, `gender`, `dob`,
    `caste`, `category`, `gotra`, `religion`, `marital_status`, `blood_group`,
    `address_line1`, `pin_code`, `district`, `state`, `country`,
    `is_claimed`, `status`
) VALUES
('109284729102', 'Kailash', 'Prasad', 'Sharma', 'Male', '1932-03-10', 'Brahmin', 'GEN', 'Bharadwaj', 'Hindu', 'Married', 'A+', '42 Heritage Colony', '452001', 'Indore', 'Madhya Pradesh', 'India', TRUE, 'Active'),
('109284729103', 'Savitri', 'Devi', 'Sharma', 'Female', '1935-06-15', 'Brahmin', 'GEN', 'Kashyap', 'Hindu', 'Married', 'A-', '42 Heritage Colony', '452001', 'Indore', 'Madhya Pradesh', 'India', TRUE, 'Active'),
('000021000274', 'Ramesh', 'Kumar', 'Jatav', 'Male', '1932-04-11', 'Jatav', 'SC', 'Kashyap', 'Hindu', 'Married', 'B+', '15 Shyamla Hills', '462001', 'Bhopal', 'Madhya Pradesh', 'India', TRUE, 'Active'),
('000031000411', 'Sunita', 'Kumari', 'Jatav', 'Female', '1935-07-16', 'Jatav', 'SC', 'Gautam', 'Hindu', 'Married', 'B-', '15 Shyamla Hills', '462001', 'Bhopal', 'Madhya Pradesh', 'India', TRUE, 'Active'),
('000041000548', 'Deepak', 'Singh', 'Bhil', 'Male', '1932-05-12', 'Meena', 'ST', 'Gautam', 'Hindu', 'Married', 'O+', '89 Malviya Nagar', '302001', 'Jaipur', 'Rajasthan', 'India', TRUE, 'Active'),
('000051000685', 'Meena', 'Bai', 'Bhil', 'Female', '1935-08-17', 'Meena', 'ST', 'Vashishta', 'Hindu', 'Married', 'O-', '89 Malviya Nagar', '302001', 'Jaipur', 'Rajasthan', 'India', TRUE, 'Active'),
('000061000822', 'Vikram', 'Lal', 'Sahu', 'Male', '1932-06-13', 'Teli', 'OBC', 'Vashishta', 'Jain', 'Married', 'AB+', '34 Gomti Nagar', '226001', 'Lucknow', 'Uttar Pradesh', 'India', TRUE, 'Active'),
('000071000959', 'Anita', 'Rani', 'Sahu', 'Female', '1935-09-18', 'Teli', 'OBC', 'Vatsa', 'Jain', 'Married', 'AB-', '34 Gomti Nagar', '226001', 'Lucknow', 'Uttar Pradesh', 'India', TRUE, 'Active'),
('010081011096', 'Aarav', NULL, 'Sharma', 'Male', '1955-02-10', 'Rajput', 'GEN', 'Kashyap', 'Hindu', 'Married', 'B-', '7 Koregaon Park', '411001', 'Pune', 'Maharashtra', 'India', TRUE, 'Active'),
('010091011233', 'Pooja', 'Sharma', 'Sahu', 'Female', '1957-05-12', 'Rajput', 'GEN', 'Gautam', 'Hindu', 'Married', 'O+', '7 Koregaon Park', '411001', 'Pune', 'Maharashtra', 'India', TRUE, 'Active'),
('010101011370', 'Ishaan', NULL, 'Jatav', 'Male', '1955-03-11', 'Mahar', 'SC', 'Gautam', 'Hindu', 'Married', 'O+', '22 Navrangpura', '380001', 'Ahmedabad', 'Gujarat', 'India', TRUE, 'Active'),
('010111011507', 'Ananya', 'Jatav', 'Sharma', 'Female', '1957-06-13', 'Mahar', 'SC', 'Vashishta', 'Hindu', 'Married', 'O-', '22 Navrangpura', '380001', 'Ahmedabad', 'Gujarat', 'India', TRUE, 'Active'),
('010121011644', 'Rahul', NULL, 'Bhil', 'Male', '1955-04-12', 'Santhal', 'ST', 'Vashishta', 'Jain', 'Married', 'O-', '56 Lanka', '221001', 'Varanasi', 'Uttar Pradesh', 'India', TRUE, 'Active'),
('010131011781', 'Priya', 'Bhil', 'Jatav', 'Female', '1957-07-14', 'Santhal', 'ST', 'Vatsa', 'Jain', 'Married', 'AB+', '56 Lanka', '221001', 'Varanasi', 'Uttar Pradesh', 'India', TRUE, 'Active'),
('010141011918', 'Kabir', NULL, 'Sahu', 'Male', '1955-05-13', 'Gujar', 'OBC', 'Vatsa', 'Buddhist', 'Married', 'AB+', '3 Mahakal Rd', '456001', 'Ujjain', 'Madhya Pradesh', 'India', TRUE, 'Active'),
('010151012055', 'Diya', 'Sahu', 'Bhil', 'Female', '1957-08-15', 'Gujar', 'OBC', 'Shandilya', 'Buddhist', 'Married', 'AB-', '3 Mahakal Rd', '456001', 'Ujjain', 'Madhya Pradesh', 'India', TRUE, 'Active'),
('020161022192', 'Rohan', NULL, 'Sharma', 'Male', '1978-02-10', 'Kayastha', 'GEN', 'Gautam', 'Hindu', 'Married', 'AB+', '42 Heritage Colony', '452001', 'Indore', 'Madhya Pradesh', 'India', TRUE, 'Active'),
('020171022329', 'Kavita', 'Sharma', 'Sahu', 'Female', '1980-05-12', 'Kayastha', 'GEN', 'Vashishta', 'Hindu', 'Married', 'AB-', '42 Heritage Colony', '452001', 'Indore', 'Madhya Pradesh', 'India', TRUE, 'Active'),
('020181022466', 'Vihaan', NULL, 'Jatav', 'Male', '1978-03-11', 'Valmiki', 'SC', 'Vashishta', 'Jain', 'Married', 'AB-', '15 Shyamla Hills', '462001', 'Bhopal', 'Madhya Pradesh', 'India', TRUE, 'Active'),
('020191022603', 'Riya', 'Jatav', 'Sharma', 'Female', '1980-06-13', 'Valmiki', 'SC', 'Vatsa', 'Jain', 'Married', 'A+', '15 Shyamla Hills', '462001', 'Bhopal', 'Madhya Pradesh', 'India', TRUE, 'Active'),
('020201022740', 'Advait', NULL, 'Bhil', 'Male', '1978-04-12', 'Oraon', 'ST', 'Vatsa', 'Buddhist', 'Married', 'A+', '89 Malviya Nagar', '302001', 'Jaipur', 'Rajasthan', 'India', TRUE, 'Active'),
('020211022877', 'Kavya', 'Bhil', 'Jatav', 'Female', '1980-07-14', 'Oraon', 'ST', 'Shandilya', 'Buddhist', 'Married', 'A-', '89 Malviya Nagar', '302001', 'Jaipur', 'Rajasthan', 'India', TRUE, 'Active'),
('020221023014', 'Devendra', NULL, 'Sahu', 'Male', '1978-05-13', 'Yadav', 'OBC', 'Shandilya', 'Sikh', 'Married', 'A-', '34 Gomti Nagar', '226001', 'Lucknow', 'Uttar Pradesh', 'India', TRUE, 'Active'),
('020231023151', 'Phoolmati', 'Sahu', 'Bhil', 'Female', '1980-08-15', 'Yadav', 'OBC', 'Atri', 'Sikh', 'Married', 'B+', '34 Gomti Nagar', '226001', 'Lucknow', 'Uttar Pradesh', 'India', TRUE, 'Active'),
('030241033288', 'Suresh', NULL, 'Sharma', 'Male', '2001-02-10', 'Khatri', 'GEN', 'Vashishta', 'Jain', 'Married', 'A-', '7 Koregaon Park', '411001', 'Pune', 'Maharashtra', 'India', TRUE, 'Active'),
('030251033425', 'Neha', 'Sharma', 'Sahu', 'Female', '2003-05-12', 'Khatri', 'GEN', 'Vatsa', 'Jain', 'Married', 'B+', '7 Koregaon Park', '411001', 'Pune', 'Maharashtra', 'India', TRUE, 'Active'),
('030261033562', 'Ramcharan', NULL, 'Jatav', 'Male', '2001-03-11', 'Dhobi', 'SC', 'Vatsa', 'Buddhist', 'Married', 'B+', '22 Navrangpura', '380001', 'Ahmedabad', 'Gujarat', 'India', TRUE, 'Active'),
('030271033699', 'Ritu', 'Jatav', 'Sharma', 'Female', '2003-06-13', 'Dhobi', 'SC', 'Shandilya', 'Buddhist', 'Married', 'B-', '22 Navrangpura', '380001', 'Ahmedabad', 'Gujarat', 'India', TRUE, 'Active'),
('030281033836', 'Amit', NULL, 'Bhil', 'Male', '2001-04-12', 'Gond', 'ST', 'Shandilya', 'Sikh', 'Married', 'B-', '56 Lanka', '221001', 'Varanasi', 'Uttar Pradesh', 'India', TRUE, 'Active'),
('030291033973', 'Shweta', 'Bhil', 'Jatav', 'Female', '2003-07-14', 'Gond', 'ST', 'Atri', 'Sikh', 'Married', 'O+', '56 Lanka', '221001', 'Varanasi', 'Uttar Pradesh', 'India', TRUE, 'Active'),
('030301034110', 'Sanjay', NULL, 'Sahu', 'Male', '2001-05-13', 'Kurmi', 'OBC', 'Atri', 'Hindu', 'Married', 'O+', '3 Mahakal Rd', '456001', 'Ujjain', 'Madhya Pradesh', 'India', TRUE, 'Active'),
('030311034247', 'Nisha', 'Sahu', 'Bhil', 'Female', '2003-08-15', 'Kurmi', 'OBC', 'Kaushik', 'Hindu', 'Married', 'O-', '3 Mahakal Rd', '456001', 'Ujjain', 'Madhya Pradesh', 'India', TRUE, 'Active'),
('040321044384', 'Manish', NULL, 'Sharma', 'Male', '2024-02-10', 'Vaishya', 'GEN', 'Vatsa', 'Buddhist', 'Single', 'O+', '42 Heritage Colony', '452001', 'Indore', 'Madhya Pradesh', 'India', TRUE, 'Active'),
('040331044521', 'Aarti', NULL, 'Sharma', 'Female', '2026-05-12', 'Vaishya', 'GEN', 'Shandilya', 'Buddhist', 'Single', 'O-', '42 Heritage Colony', '452001', 'Indore', 'Madhya Pradesh', 'India', TRUE, 'Active'),
('040341044658', 'Karan', NULL, 'Jatav', 'Male', '2024-03-11', 'Chamar', 'SC', 'Shandilya', 'Sikh', 'Single', 'O-', '15 Shyamla Hills', '462001', 'Bhopal', 'Madhya Pradesh', 'India', TRUE, 'Active'),
('040351044795', 'Sanya', NULL, 'Jatav', 'Female', '2026-06-13', 'Chamar', 'SC', 'Atri', 'Sikh', 'Single', 'AB+', '15 Shyamla Hills', '462001', 'Bhopal', 'Madhya Pradesh', 'India', TRUE, 'Active'),
('040361044932', 'Aditya', NULL, 'Bhil', 'Male', '2024-04-12', 'Bhil', 'ST', 'Atri', 'Hindu', 'Single', 'AB+', '89 Malviya Nagar', '302001', 'Jaipur', 'Rajasthan', 'India', TRUE, 'Active'),
('040371045069', 'Tanvi', NULL, 'Bhil', 'Female', '2026-07-14', 'Bhil', 'ST', 'Kaushik', 'Hindu', 'Single', 'AB-', '89 Malviya Nagar', '302001', 'Jaipur', 'Rajasthan', 'India', TRUE, 'Active'),
('040381045206', 'Arjun', NULL, 'Sahu', 'Male', '2024-05-13', 'Jat', 'OBC', 'Kaushik', 'Hindu', 'Single', 'AB-', '34 Gomti Nagar', '226001', 'Lucknow', 'Uttar Pradesh', 'India', TRUE, 'Active'),
('040391045343', 'Isha', NULL, 'Sahu', 'Female', '2026-08-15', 'Jat', 'OBC', 'Bharadwaj', 'Hindu', 'Single', 'A+', '34 Gomti Nagar', '226001', 'Lucknow', 'Uttar Pradesh', 'India', TRUE, 'Active');

-- ----------------------------------------------------------------------------
-- 2. Insert Lineage Kinship Relationships
-- ----------------------------------------------------------------------------
INSERT INTO `relationships` (
    `source_vuid`, `target_vuid`, `relationship_type`, `verification_status`
) VALUES
('109284729102', '109284729103', 'Spouse', 'Mutual_Confirmed'),
('000021000274', '000031000411', 'Spouse', 'Mutual_Confirmed'),
('000041000548', '000051000685', 'Spouse', 'Mutual_Confirmed'),
('000061000822', '000071000959', 'Spouse', 'Mutual_Confirmed'),
('109284729102', '010081011096', 'Father', 'Document_Backed'),
('109284729103', '010081011096', 'Mother', 'Document_Backed'),
('109284729102', '010091011233', 'Father', 'Document_Backed'),
('109284729103', '010091011233', 'Mother', 'Document_Backed'),
('000021000274', '010101011370', 'Father', 'Document_Backed'),
('000031000411', '010101011370', 'Mother', 'Document_Backed'),
('000021000274', '010111011507', 'Father', 'Document_Backed'),
('000031000411', '010111011507', 'Mother', 'Document_Backed'),
('000041000548', '010121011644', 'Father', 'Document_Backed'),
('000051000685', '010121011644', 'Mother', 'Document_Backed'),
('000041000548', '010131011781', 'Father', 'Document_Backed'),
('000051000685', '010131011781', 'Mother', 'Document_Backed'),
('000061000822', '010141011918', 'Father', 'Document_Backed'),
('000071000959', '010141011918', 'Mother', 'Document_Backed'),
('000061000822', '010151012055', 'Father', 'Document_Backed'),
('000071000959', '010151012055', 'Mother', 'Document_Backed'),
('010081011096', '010111011507', 'Spouse', 'Mutual_Confirmed'),
('010101011370', '010131011781', 'Spouse', 'Mutual_Confirmed'),
('010121011644', '010151012055', 'Spouse', 'Mutual_Confirmed'),
('010141011918', '010091011233', 'Spouse', 'Mutual_Confirmed'),
('010081011096', '020161022192', 'Father', 'Document_Backed'),
('010111011507', '020161022192', 'Mother', 'Document_Backed'),
('010081011096', '020171022329', 'Father', 'Document_Backed'),
('010111011507', '020171022329', 'Mother', 'Document_Backed'),
('010101011370', '020181022466', 'Father', 'Document_Backed'),
('010131011781', '020181022466', 'Mother', 'Document_Backed'),
('010101011370', '020191022603', 'Father', 'Document_Backed'),
('010131011781', '020191022603', 'Mother', 'Document_Backed'),
('010121011644', '020201022740', 'Father', 'Document_Backed'),
('010151012055', '020201022740', 'Mother', 'Document_Backed'),
('010121011644', '020211022877', 'Father', 'Document_Backed'),
('010151012055', '020211022877', 'Mother', 'Document_Backed'),
('010141011918', '020221023014', 'Father', 'Document_Backed'),
('010091011233', '020221023014', 'Mother', 'Document_Backed'),
('010141011918', '020231023151', 'Father', 'Document_Backed'),
('010091011233', '020231023151', 'Mother', 'Document_Backed'),
('020161022192', '020191022603', 'Spouse', 'Mutual_Confirmed'),
('020181022466', '020211022877', 'Spouse', 'Mutual_Confirmed'),
('020201022740', '020231023151', 'Spouse', 'Mutual_Confirmed'),
('020221023014', '020171022329', 'Spouse', 'Mutual_Confirmed'),
('020161022192', '030241033288', 'Father', 'Document_Backed'),
('020191022603', '030241033288', 'Mother', 'Document_Backed'),
('020161022192', '030251033425', 'Father', 'Document_Backed'),
('020191022603', '030251033425', 'Mother', 'Document_Backed'),
('020181022466', '030261033562', 'Father', 'Document_Backed'),
('020211022877', '030261033562', 'Mother', 'Document_Backed'),
('020181022466', '030271033699', 'Father', 'Document_Backed'),
('020211022877', '030271033699', 'Mother', 'Document_Backed'),
('020201022740', '030281033836', 'Father', 'Document_Backed'),
('020231023151', '030281033836', 'Mother', 'Document_Backed'),
('020201022740', '030291033973', 'Father', 'Document_Backed'),
('020231023151', '030291033973', 'Mother', 'Document_Backed'),
('020221023014', '030301034110', 'Father', 'Document_Backed'),
('020171022329', '030301034110', 'Mother', 'Document_Backed'),
('020221023014', '030311034247', 'Father', 'Document_Backed'),
('020171022329', '030311034247', 'Mother', 'Document_Backed'),
('030241033288', '030271033699', 'Spouse', 'Mutual_Confirmed'),
('030261033562', '030291033973', 'Spouse', 'Mutual_Confirmed'),
('030281033836', '030311034247', 'Spouse', 'Mutual_Confirmed'),
('030301034110', '030251033425', 'Spouse', 'Mutual_Confirmed'),
('030241033288', '040321044384', 'Father', 'Document_Backed'),
('030271033699', '040321044384', 'Mother', 'Document_Backed'),
('030241033288', '040331044521', 'Father', 'Document_Backed'),
('030271033699', '040331044521', 'Mother', 'Document_Backed'),
('030261033562', '040341044658', 'Father', 'Document_Backed'),
('030291033973', '040341044658', 'Mother', 'Document_Backed'),
('030261033562', '040351044795', 'Father', 'Document_Backed'),
('030291033973', '040351044795', 'Mother', 'Document_Backed'),
('030281033836', '040361044932', 'Father', 'Document_Backed'),
('030311034247', '040361044932', 'Mother', 'Document_Backed'),
('030281033836', '040371045069', 'Father', 'Document_Backed'),
('030311034247', '040371045069', 'Mother', 'Document_Backed'),
('030301034110', '040381045206', 'Father', 'Document_Backed'),
('030251033425', '040381045206', 'Mother', 'Document_Backed'),
('030301034110', '040391045343', 'Father', 'Document_Backed'),
('030251033425', '040391045343', 'Mother', 'Document_Backed');

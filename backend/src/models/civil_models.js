/**
 * VanshaSetu — Canonical Civil Domain Models & Validation Standards
 * Single Source of Truth: shared/civil_models.json
 * Constitutional Invariant: NO default values, NO placeholders, NO silent alternatives.
 * Operations MUST succeed with valid values or FAIL explicitly.
 */

const modelsData = require('../../../shared/civil_models.json');

// Code arrays
const CATEGORIES = Object.freeze(modelsData.categories.map(c => c.code));
const RELIGIONS = Object.freeze(modelsData.religions.map(r => r.code));
const MARITAL_STATUSES = Object.freeze(modelsData.marital_statuses.map(m => m.code));
const BLOOD_GROUPS = Object.freeze(modelsData.blood_groups.map(b => b.code));
const GENDERS = Object.freeze(modelsData.genders.map(g => g.code));
const RELATIONSHIPS = Object.freeze(modelsData.relationships.map(r => r.code));
const QUALIFICATION_LEVELS = Object.freeze(modelsData.qualifications.map(q => q.code));
const OCCUPATION_SECTORS = Object.freeze(modelsData.occupations.map(o => o.code));
const DOCUMENT_TYPES = Object.freeze(modelsData.document_types.map(d => d.code));

// Supported Languages (derived directly from SSOT shared/civil_models.json - NO defaults/fallbacks)
const SUPPORTED_LANGUAGES = Object.freeze(modelsData.supported_languages);
const SUPPORTED_LANGUAGE_CODES = Object.freeze(SUPPORTED_LANGUAGES.map(l => l.code));

// String Label mappings (English)
const CATEGORY_LABELS = Object.freeze(Object.fromEntries(modelsData.categories.map(c => [c.code, c.label])));
const RELIGION_LABELS = Object.freeze(Object.fromEntries(modelsData.religions.map(r => [r.code, r.label])));
const MARITAL_STATUS_LABELS = Object.freeze(Object.fromEntries(modelsData.marital_statuses.map(m => [m.code, m.label])));
const BLOOD_GROUP_LABELS = Object.freeze(Object.fromEntries(modelsData.blood_groups.map(b => [b.code, b.label])));
const GENDER_LABELS = Object.freeze(Object.fromEntries(modelsData.genders.map(g => [g.code, g.label])));
const RELATIONSHIP_LABELS = Object.freeze(Object.fromEntries(modelsData.relationships.map(r => [r.code, r.label])));
const RELATIONSHIP_WESTERN = Object.freeze(Object.fromEntries(modelsData.relationships.map(r => [r.code, r.western])));
const RELATIONSHIP_INDIAN = Object.freeze(Object.fromEntries(modelsData.relationships.map(r => [r.code, r.indian])));
const RELATIONSHIP_CATEGORIES = Object.freeze(Object.fromEntries(modelsData.relationships.map(r => [r.code, r.category])));
const QUALIFICATION_LABELS = Object.freeze(Object.fromEntries(modelsData.qualifications.map(q => [q.code, q.label])));
const OCCUPATION_LABELS = Object.freeze(Object.fromEntries(modelsData.occupations.map(o => [o.code, o.label])));
const DOCUMENT_TYPE_LABELS = Object.freeze(Object.fromEntries(modelsData.document_types.map(d => [d.code, d.label])));

// Hindi Label mappings
const CATEGORY_LABELS_HI = Object.freeze(Object.fromEntries(modelsData.categories.map(c => [c.code, c.hindi_label])));
const RELIGION_LABELS_HI = Object.freeze(Object.fromEntries(modelsData.religions.map(r => [r.code, r.hindi_label])));
const MARITAL_STATUS_LABELS_HI = Object.freeze(Object.fromEntries(modelsData.marital_statuses.map(m => [m.code, m.hindi_label])));
const BLOOD_GROUP_LABELS_HI = Object.freeze(Object.fromEntries(modelsData.blood_groups.map(b => [b.code, b.hindi_label])));
const GENDER_LABELS_HI = Object.freeze(Object.fromEntries(modelsData.genders.map(g => [g.code, g.hindi_label])));
const RELATIONSHIP_LABELS_HI = Object.freeze(Object.fromEntries(modelsData.relationships.map(r => [r.code, r.hindi_label])));

// Gujarati Label mappings
const CATEGORY_LABELS_GU = Object.freeze(Object.fromEntries(modelsData.categories.map(c => [c.code, c.gujarati_label || c.label])));
const RELIGION_LABELS_GU = Object.freeze(Object.fromEntries(modelsData.religions.map(r => [r.code, r.gujarati_label || r.label])));
const MARITAL_STATUS_LABELS_GU = Object.freeze(Object.fromEntries(modelsData.marital_statuses.map(m => [m.code, m.gujarati_label || m.label])));
const BLOOD_GROUP_LABELS_GU = Object.freeze(Object.fromEntries(modelsData.blood_groups.map(b => [b.code, b.gujarati_label || b.label])));
const GENDER_LABELS_GU = Object.freeze(Object.fromEntries(modelsData.genders.map(g => [g.code, g.gujarati_label || g.label])));
const RELATIONSHIP_LABELS_GU = Object.freeze(Object.fromEntries(modelsData.relationships.map(r => [r.code, r.gujarati_label || r.label])));

// Marathi Label mappings
const CATEGORY_LABELS_MR = Object.freeze(Object.fromEntries(modelsData.categories.map(c => [c.code, c.marathi_label || c.label])));
const RELIGION_LABELS_MR = Object.freeze(Object.fromEntries(modelsData.religions.map(r => [r.code, r.marathi_label || r.label])));
const MARITAL_STATUS_LABELS_MR = Object.freeze(Object.fromEntries(modelsData.marital_statuses.map(m => [m.code, m.marathi_label || m.label])));
const BLOOD_GROUP_LABELS_MR = Object.freeze(Object.fromEntries(modelsData.blood_groups.map(b => [b.code, b.marathi_label || b.label])));
const GENDER_LABELS_MR = Object.freeze(Object.fromEntries(modelsData.genders.map(g => [g.code, g.marathi_label || g.label])));
const RELATIONSHIP_LABELS_MR = Object.freeze(Object.fromEntries(modelsData.relationships.map(r => [r.code, r.marathi_label || r.label])));

/**
 * Returns localized label for a given model and code.
 * @param {'categories'|'religions'|'marital_statuses'|'blood_groups'|'genders'|'relationships'|'qualifications'|'occupations'|'document_types'} modelKey 
 * @param {string} code 
 * @param {'en'|'hi'|'gu'|'mr'} lang 
 * @returns {string} Localized label string
 */
function getLocalizedLabel(modelKey, code, lang = 'en') {
    const list = modelsData[modelKey];
    if (!list) return code;
    const item = list.find(i => i.code === code);
    if (!item) return code;
    switch ((lang || 'en').toLowerCase()) {
        case 'hi': return item.hindi_label || item.label;
        case 'gu': return item.gujarati_label || item.label;
        case 'mr': return item.marathi_label || item.label;
        case 'en':
        default:
            return item.label;
    }
}

/**
 * Validates religion against canonical Indian civil list.
 * @param {string} val 
 * @returns {string|null} Error message or null if valid.
 */
function validateReligion(val) {
    if (!val || typeof val !== 'string' || !val.trim()) {
        return 'Religion is mandatory and must not be empty.';
    }
    if (!RELIGIONS.includes(val.trim())) {
        return `Invalid religion '${val}'. Must be one of: ${RELIGIONS.join(', ')}`;
    }
    return null;
}

/**
 * Validates marital status against canonical options.
 * @param {string} val 
 * @returns {string|null} Error message or null if valid.
 */
function validateMaritalStatus(val) {
    if (!val || typeof val !== 'string' || !val.trim()) {
        return 'Marital status is mandatory and must not be empty.';
    }
    if (!MARITAL_STATUSES.includes(val.trim())) {
        return `Invalid marital_status '${val}'. Must be one of: ${MARITAL_STATUSES.join(', ')}`;
    }
    return null;
}

/**
 * Validates social category against constitutional reservation categories.
 * @param {string} val 
 * @returns {string|null} Error message or null if valid.
 */
function validateCategory(val) {
    if (!val || typeof val !== 'string' || !val.trim()) {
        return 'Category is mandatory and must not be empty.';
    }
    if (!CATEGORIES.includes(val.trim())) {
        return `Invalid category '${val}'. Must be one of: ${CATEGORIES.join(', ')}`;
    }
    return null;
}

/**
 * Validates ABO/Rh blood group.
 * @param {string} val 
 * @returns {string|null} Error message or null if valid.
 */
function validateBloodGroup(val) {
    if (!val || typeof val !== 'string' || !val.trim()) {
        return 'Blood group is mandatory and must not be empty.';
    }
    if (!BLOOD_GROUPS.includes(val.trim())) {
        return `Invalid blood_group '${val}'. Must be one of: ${BLOOD_GROUPS.join(', ')}`;
    }
    return null;
}

/**
 * Validates Gotra / ancestral clan lineage identifier.
 * @param {string} val 
 * @returns {string|null} Error message or null if valid.
 */
function validateGotra(val) {
    if (!val || typeof val !== 'string' || !val.trim()) {
        return 'Gotra is mandatory and must not be empty.';
    }
    if (val.trim().length > 80) {
        return 'Gotra cannot exceed 80 characters.';
    }
    return null;
}

/**
 * Validates community / caste identifier.
 * @param {string} val 
 * @returns {string|null} Error message or null if valid.
 */
function validateCaste(val) {
    if (!val || typeof val !== 'string' || !val.trim()) {
        return 'Caste is mandatory and must not be empty.';
    }
    if (val.trim().length > 80) {
        return 'Caste cannot exceed 80 characters.';
    }
    return null;
}

/**
 * Validates gender.
 * @param {string} val 
 * @returns {string|null} Error message or null if valid.
 */
function validateGender(val) {
    if (!val || typeof val !== 'string' || !val.trim()) {
        return 'Gender is mandatory and must not be empty.';
    }
    if (!GENDERS.includes(val.trim())) {
        return `Invalid gender '${val}'. Must be one of: ${GENDERS.join(', ')}`;
    }
    return null;
}

/**
 * Validates relationship type for kinship directed graph.
 * @param {string} val 
 * @returns {string|null} Error message or null if valid.
 */
function validateRelationship(val) {
    if (!val || typeof val !== 'string' || !val.trim()) {
        return 'Relationship type is mandatory and must not be empty.';
    }
    if (!RELATIONSHIPS.includes(val.trim())) {
        return `Invalid relationship_type '${val}'. Must be one of: ${RELATIONSHIPS.join(', ')}`;
    }
    return null;
}

/**
 * Validates educational qualification level.
 * @param {string} val 
 * @returns {string|null} Error message or null if valid.
 */
function validateQualificationLevel(val) {
    if (!val || typeof val !== 'string' || !val.trim()) {
        return 'Qualification level is mandatory and must not be empty.';
    }
    if (!QUALIFICATION_LEVELS.includes(val.trim())) {
        return `Invalid qualification_level '${val}'. Must be one of: ${QUALIFICATION_LEVELS.join(', ')}`;
    }
    return null;
}

/**
 * Validates professional occupation sector.
 * @param {string} val 
 * @returns {string|null} Error message or null if valid.
 */
function validateOccupationSector(val) {
    if (!val || typeof val !== 'string' || !val.trim()) {
        return 'Occupation sector is mandatory and must not be empty.';
    }
    if (!OCCUPATION_SECTORS.includes(val.trim())) {
        return `Invalid occupation_sector '${val}'. Must be one of: ${OCCUPATION_SECTORS.join(', ')}`;
    }
    return null;
}

/**
 * Validates government / civil identity document type.
 * @param {string} val 
 * @returns {string|null} Error message or null if valid.
 */
function validateDocumentType(val) {
    if (!val || typeof val !== 'string' || !val.trim()) {
        return 'Document type is mandatory and must not be empty.';
    }
    if (!DOCUMENT_TYPES.includes(val.trim())) {
        return `Invalid doc_type '${val}'. Must be one of: ${DOCUMENT_TYPES.join(', ')}`;
    }
    return null;
}

module.exports = {
    RAW_CIVIL_MODELS: modelsData,
    SUPPORTED_LANGUAGES,
    SUPPORTED_LANGUAGE_CODES,
    CATEGORIES,
    RELIGIONS,
    MARITAL_STATUSES,
    BLOOD_GROUPS,
    GENDERS,
    RELATIONSHIPS,
    QUALIFICATION_LEVELS,
    OCCUPATION_SECTORS,
    DOCUMENT_TYPES,
    CATEGORY_LABELS,
    RELIGION_LABELS,
    MARITAL_STATUS_LABELS,
    BLOOD_GROUP_LABELS,
    GENDER_LABELS,
    RELATIONSHIP_LABELS,
    RELATIONSHIP_WESTERN,
    RELATIONSHIP_INDIAN,
    RELATIONSHIP_CATEGORIES,
    QUALIFICATION_LABELS,
    OCCUPATION_LABELS,
    DOCUMENT_TYPE_LABELS,
    CATEGORY_LABELS_HI,
    CATEGORY_LABELS_GU,
    CATEGORY_LABELS_MR,
    RELATIONSHIP_LABELS_HI,
    RELATIONSHIP_LABELS_GU,
    RELATIONSHIP_LABELS_MR,
    getLocalizedLabel,
    validateReligion,
    validateMaritalStatus,
    validateCategory,
    validateBloodGroup,
    validateGotra,
    validateCaste,
    validateGender,
    validateRelationship,
    validateQualificationLevel,
    validateOccupationSector,
    validateDocumentType
};

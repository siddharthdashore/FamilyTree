const fs = require('fs');
const path = require('path');

// ============================================================================
// VanshaSetu 5-Layer Hierarchical Family Database Generator
// Layer 0: 8 root members (4 couples) — GEN, SC, ST, OBC
// Layers 1-4: Each couple produces 2 children (1 boy, 1 girl).
//   Children marry spouses from DIFFERENT families (no sibling marriages).
// ============================================================================

const categories = ['GEN', 'SC', 'ST', 'OBC'];
const castesMap = {
  GEN: ['Brahmin', 'Rajput', 'Kayastha', 'Khatri', 'Vaishya'],
  SC:  ['Chamar', 'Jatav', 'Mahar', 'Valmiki', 'Dhobi'],
  ST:  ['Gond', 'Bhil', 'Meena', 'Santhal', 'Oraon'],
  OBC: ['Yadav', 'Kurmi', 'Jat', 'Teli', 'Gujar']
};
const lastNameMap = {
  GEN: ['Sharma', 'Mishra', 'Trivedi', 'Pandey', 'Dubey'],
  SC:  ['Paswan', 'Jatav', 'Gautan', 'Kumar', 'Rathore'],
  ST:  ['Gond', 'Meena', 'Bhil', 'Munda', 'Kol'],
  OBC: ['Patel', 'Yadav', 'Gupta', 'Sahu', 'Verma']
};
const gotras = ['Bharadwaj', 'Kashyap', 'Gautam', 'Vashishta', 'Vatsa', 'Shandilya', 'Atri', 'Kaushik'];
const bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
const religions = ['Hindu', 'Hindu', 'Hindu', 'Jain', 'Buddhist', 'Sikh'];

const cities = [
  { district: 'Indore', state: 'Madhya Pradesh', pin: '452001', addr: '42 Heritage Colony' },
  { district: 'Bhopal', state: 'Madhya Pradesh', pin: '462001', addr: '15 Shyamla Hills' },
  { district: 'Jaipur', state: 'Rajasthan', pin: '302001', addr: '89 Malviya Nagar' },
  { district: 'Lucknow', state: 'Uttar Pradesh', pin: '226001', addr: '34 Gomti Nagar' },
  { district: 'Pune', state: 'Maharashtra', pin: '411001', addr: '7 Koregaon Park' },
  { district: 'Ahmedabad', state: 'Gujarat', pin: '380001', addr: '22 Navrangpura' },
  { district: 'Varanasi', state: 'Uttar Pradesh', pin: '221001', addr: '56 Lanka' },
  { district: 'Ujjain', state: 'Madhya Pradesh', pin: '456001', addr: '3 Mahakal Rd' },
];

const maleNames = [
  'Kailash', 'Ramesh', 'Deepak', 'Vikram', 'Aarav', 'Ishaan', 'Rahul', 'Kabir',
  'Rohan', 'Vihaan', 'Advait', 'Devendra', 'Suresh', 'Ramcharan', 'Amit', 'Sanjay',
  'Manish', 'Karan', 'Aditya', 'Arjun', 'Reyansh', 'Vivaan', 'Dhruv', 'Yash',
  'Anay', 'Shlok', 'Pranav', 'Nikhil', 'Harsh', 'Gaurav', 'Kunal', 'Ravi',
  'Arnav', 'Lakshya', 'Parth', 'Tejas', 'Nakul', 'Rudra', 'Virat', 'Moksh'
];
const femaleNames = [
  'Savitri', 'Sunita', 'Meena', 'Anita', 'Pooja', 'Ananya', 'Priya', 'Diya',
  'Kavita', 'Riya', 'Kavya', 'Phoolmati', 'Neha', 'Ritu', 'Shweta', 'Nisha',
  'Aarti', 'Sanya', 'Tanvi', 'Isha', 'Khushi', 'Myra', 'Aadhya', 'Anvi',
  'Tara', 'Swati', 'Geeta', 'Lata', 'Seema', 'Manju', 'Rekha', 'Pallavi',
  'Suman', 'Kamla', 'Usha', 'Radha', 'Anika', 'Kiara', 'Shreya', 'Divya'
];

const middleNamesM = ['Prasad', 'Kumar', 'Singh', 'Lal', 'Nath', 'Chandra', 'Bahadur', 'Ram'];
const middleNamesF = ['Devi', 'Kumari', 'Bai', 'Rani', null, null, null, null];

const citizens = [];
const relationships = [];

let citizenIdCounter = 1;
let maleNameIdx = 0;
let femaleNameIdx = 0;

function nextMaleName() { return maleNames[maleNameIdx++ % maleNames.length]; }
function nextFemaleName() { return femaleNames[femaleNameIdx++ % femaleNames.length]; }

// Generate deterministic 12-digit VUID from layer + index
function makeVUID(layer, index) {
  if (layer === 0 && index === 0) return '109284729102'; // Kailash Sharma
  if (layer === 0 && index === 1) return '109284729103'; // Savitri Sharma
  if (layer === 1 && index === 0) return '284910293847'; // Aarav (for E2E test doc)
  if (layer === 1 && index === 1) return '928174019284'; // Pooja
  const layerStr = String(layer).padStart(2, '0');
  const indexStr = String(index).padStart(3, '0');
  const suffix = String(1000000 + layer * 10000 + index * 137).padStart(7, '0');
  return `${layerStr}${indexStr}${suffix}`;
}

// Birth years per layer (5 layers). Inter-layer spacing (23y) guarantees every
// parent is strictly >18 at each child's birth, and the last layer stays <= today.
const birthYears = [1932, 1955, 1978, 2001, 2024];

// ============================================================================
// Layer 0: Root generation — 8 members (4 couples), one per category
// ============================================================================
const layer0Couples = [];
let globalIdx = 0;

for (let c = 0; c < categories.length; c++) {
  const cat = categories[c];
  const caste = castesMap[cat][c % castesMap[cat].length];
  const lastName = lastNameMap[cat][c % lastNameMap[cat].length];
  const city = cities[c % cities.length];
  const husbandVuid = makeVUID(0, globalIdx);
  const wifeVuid    = makeVUID(0, globalIdx + 1);

  citizens.push({
    vuid: husbandVuid, first_name: nextMaleName(), middle_name: middleNamesM[c % middleNamesM.length],
    last_name: lastName, gender: 'Male', dob: `${birthYears[0]}-0${3 + c}-${10 + c}`,
    caste, category: cat, gotra: gotras[c % gotras.length], religion: religions[c % religions.length],
    marital_status: 'Married', blood_group: bloodGroups[(c * 2) % bloodGroups.length],
    address_line1: city.addr, pin_code: city.pin, district: city.district, state: city.state, country: 'India',
    is_claimed: 1, status: 'Active', created_at: '2026-01-01T00:00:00.000Z'
  });

  citizens.push({
    vuid: wifeVuid, first_name: nextFemaleName(), middle_name: middleNamesF[c % middleNamesF.length],
    last_name: lastName, gender: 'Female', dob: `${birthYears[0] + 3}-0${6 + c}-${15 + c}`,
    caste, category: cat, gotra: gotras[(c + 1) % gotras.length], religion: religions[c % religions.length],
    marital_status: 'Married', blood_group: bloodGroups[(c * 2 + 1) % bloodGroups.length],
    address_line1: city.addr, pin_code: city.pin, district: city.district, state: city.state, country: 'India',
    is_claimed: 1, status: 'Active', created_at: '2026-01-01T00:00:00.000Z'
  });

  relationships.push({ source: husbandVuid, target: wifeVuid, type: 'Spouse', status: 'Mutual_Confirmed' });
  layer0Couples.push({ fatherVuid: husbandVuid, motherVuid: wifeVuid, category: cat, familyId: c, fatherLastName: lastName });
  globalIdx += 2;
}

// ============================================================================
// Layers 1–4: Each couple → 1 son + 1 daughter, cross-family marriages
// ============================================================================
let currentLayerCouples = layer0Couples;

for (let layer = 1; layer <= 4; layer++) {
  const sons = [];
  const daughters = [];

  for (let pc = 0; pc < currentLayerCouples.length; pc++) {
    const parent = currentLayerCouples[pc];
    const cat = parent.category;
    const caste = castesMap[cat][(layer + pc) % castesMap[cat].length];
    const fatherLastName = parent.fatherLastName;
    const city = cities[(layer * 4 + pc) % cities.length];

    // Last-layer members are minors — they stay Single and are never paired.
    const isLeafLayer = layer === birthYears.length - 1;

    // Son
    const sonVuid = makeVUID(layer, globalIdx);
    globalIdx++;
    citizens.push({
      vuid: sonVuid, first_name: nextMaleName(), middle_name: null,
      last_name: fatherLastName, gender: 'Male', dob: `${birthYears[layer]}-0${2 + (pc % 6)}-${10 + pc}`,
      caste, category: cat, gotra: gotras[(layer + pc) % gotras.length], religion: religions[(layer + pc) % religions.length],
      marital_status: isLeafLayer ? 'Single' : 'Married', blood_group: bloodGroups[(layer * 3 + pc) % bloodGroups.length],
      address_line1: city.addr, pin_code: city.pin, district: city.district, state: city.state, country: 'India',
      is_claimed: 1, status: 'Active', created_at: '2026-01-01T00:00:00.000Z'
    });

    relationships.push({ source: parent.fatherVuid, target: sonVuid, type: 'Father', status: 'Document_Backed' });
    relationships.push({ source: parent.motherVuid, target: sonVuid, type: 'Mother', status: 'Document_Backed' });
    sons.push({ vuid: sonVuid, lastName: fatherLastName, category: cat, familyId: parent.familyId, parentIdx: pc });

    // Daughter — born with father's surname; on marriage it moves to
    // middle_name and the husband's surname becomes her last_name.
    const dauVuid = makeVUID(layer, globalIdx);
    globalIdx++;
    const dauCitizen = {
      vuid: dauVuid, first_name: nextFemaleName(), middle_name: null,
      last_name: fatherLastName, gender: 'Female', dob: `${birthYears[layer] + 2}-0${5 + (pc % 4)}-${12 + pc}`,
      caste, category: cat, gotra: gotras[(layer + pc + 1) % gotras.length], religion: religions[(layer + pc) % religions.length],
      marital_status: isLeafLayer ? 'Single' : 'Married', blood_group: bloodGroups[(layer * 3 + pc + 1) % bloodGroups.length],
      address_line1: city.addr, pin_code: city.pin, district: city.district, state: city.state, country: 'India',
      is_claimed: 1, status: 'Active', created_at: '2026-01-01T00:00:00.000Z'
    };
    citizens.push(dauCitizen);

    relationships.push({ source: parent.fatherVuid, target: dauVuid, type: 'Father', status: 'Document_Backed' });
    relationships.push({ source: parent.motherVuid, target: dauVuid, type: 'Mother', status: 'Document_Backed' });
    daughters.push({ vuid: dauVuid, citizen: dauCitizen, fatherLastName, category: cat, familyId: parent.familyId, parentIdx: pc });
  }

  // Pair sons with daughters from DIFFERENT families (no sibling marriages).
  // Skip pairing on the leaf layer — those members are minors.
  const nextLayerCouples = [];
  const numPairs = layer < birthYears.length - 1 ? Math.min(sons.length, daughters.length) : 0;

  for (let i = 0; i < numPairs; i++) {
    const son = sons[i];
    let dauIdx = (i + 1) % numPairs;
    let attempts = 0;
    while (daughters[dauIdx].parentIdx === son.parentIdx && attempts < numPairs) {
      dauIdx = (dauIdx + 1) % numPairs;
      attempts++;
    }

    const daughter = daughters[dauIdx];

    // Married-name convention: father's surname -> middle_name,
    // husband's surname -> last_name
    daughter.citizen.middle_name = daughter.fatherLastName;
    daughter.citizen.last_name = son.lastName;

    relationships.push({ source: son.vuid, target: daughter.vuid, type: 'Spouse', status: 'Mutual_Confirmed' });

    nextLayerCouples.push({
      fatherVuid: son.vuid,
      motherVuid: daughter.vuid,
      category: son.category,
      familyId: son.familyId,
      fatherLastName: son.lastName,
    });
  }

  currentLayerCouples = nextLayerCouples;
}

// ============================================================================
// Integrity validation — a parent must be strictly >18 at a child's birth,
// no DOB may be in the future, and minors may not be marked Married.
// ============================================================================
const dobByVuid = new Map(citizens.map(c => [c.vuid, new Date(c.dob)]));
const maritalByVuid = new Map(citizens.map(c => [c.vuid, c.marital_status]));
const now = new Date();
for (const c of citizens) {
  if (dobByVuid.get(c.vuid) > now) {
    throw new Error(`Future DOB: ${c.first_name} ${c.last_name} (${c.vuid}) born ${c.dob}`);
  }
  const age = (now - dobByVuid.get(c.vuid)) / (365.25 * 24 * 3600 * 1000);
  if (age <= 18 && maritalByVuid.get(c.vuid) === 'Married') {
    throw new Error(`Minor marked Married: ${c.first_name} ${c.last_name} (${c.vuid})`);
  }
}
for (const r of relationships) {
  if (r.type !== 'Father' && r.type !== 'Mother') continue;
  const parentDob = dobByVuid.get(r.source);
  const childDob = dobByVuid.get(r.target);
  if (!parentDob || !childDob) throw new Error(`Dangling parent edge ${r.source} -> ${r.target}`);
  const parentAgeAtBirth = (childDob - parentDob) / (365.25 * 24 * 3600 * 1000);
  if (parentAgeAtBirth <= 18) {
    throw new Error(`Parent ${r.source} was ${parentAgeAtBirth.toFixed(1)} at birth of ${r.target} (must be >18)`);
  }
}

// Naming convention: sons keep the father's surname; married daughters carry
// father's surname as middle_name and husband's surname as last_name.
const citizenByVuid = new Map(citizens.map(c => [c.vuid, c]));
const spouseOf = new Map();
for (const r of relationships) {
  if (r.type === 'Spouse') {
    spouseOf.set(r.source, r.target);
    spouseOf.set(r.target, r.source);
  }
}
for (const r of relationships) {
  if (r.type !== 'Father') continue;
  const father = citizenByVuid.get(r.source);
  const child = citizenByVuid.get(r.target);
  const label = `${child.first_name} (${r.target})`;
  if (child.gender === 'Male') {
    if (child.last_name !== father.last_name) {
      throw new Error(`Surname mismatch: son ${label} has '${child.last_name}', father has '${father.last_name}'`);
    }
  } else {
    const husbandVuid = spouseOf.get(r.target);
    if (husbandVuid) {
      const husband = citizenByVuid.get(husbandVuid);
      if (child.middle_name !== father.last_name || child.last_name !== husband.last_name) {
        throw new Error(`Married-name mismatch: ${label} should be '${child.first_name} ${father.last_name} ${husband.last_name}', got '${[child.first_name, child.middle_name, child.last_name].filter(Boolean).join(' ')}'`);
      }
    } else if (child.last_name !== father.last_name) {
      throw new Error(`Unmarried daughter ${label} should keep father's surname '${father.last_name}', got '${child.last_name}'`);
    }
  }
}

// ============================================================================
// Write output directly to database/seed.sql (single source of truth)
// ============================================================================

let sql = `-- ============================================================================
-- VanshaSetu (वन्शसेतु) — Multi-Generational Seed Data (5-Layer Hierarchy)
-- Generated: ${new Date().toISOString()}
-- ============================================================================

USE \`vanshasetu_db\`;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE \`audit_logs\`;
TRUNCATE TABLE \`marriages\`;
TRUNCATE TABLE \`citizen_education\`;
TRUNCATE TABLE \`duplicate_conflict_logs\`;
TRUNCATE TABLE \`citizen_documents\`;
TRUNCATE TABLE \`relationships\`;
TRUNCATE TABLE \`citizens\`;
SET FOREIGN_KEY_CHECKS = 1;

-- ----------------------------------------------------------------------------
-- 1. Insert 5-Layer Citizens
-- ----------------------------------------------------------------------------
INSERT INTO \`citizens\` (
    \`vuid\`, \`first_name\`, \`middle_name\`, \`last_name\`, \`gender\`, \`dob\`,
    \`caste\`, \`category\`, \`gotra\`, \`religion\`, \`marital_status\`, \`blood_group\`,
    \`address_line1\`, \`pin_code\`, \`district\`, \`state\`, \`country\`,
    \`is_claimed\`, \`status\`
) VALUES
`;

const citizenValues = citizens.map(c => {
  const mid = c.middle_name ? `'${c.middle_name}'` : 'NULL';
  return `('${c.vuid}', '${c.first_name}', ${mid}, '${c.last_name}', '${c.gender}', '${c.dob}', '${c.caste}', '${c.category}', '${c.gotra}', '${c.religion}', '${c.marital_status}', '${c.blood_group}', '${c.address_line1}', '${c.pin_code}', '${c.district}', '${c.state}', '${c.country}', TRUE, '${c.status}')`;
});

sql += citizenValues.join(',\n') + ';\n\n';

sql += `-- ----------------------------------------------------------------------------
-- 2. Insert Lineage Kinship Relationships
-- ----------------------------------------------------------------------------
INSERT INTO \`relationships\` (
    \`source_vuid\`, \`target_vuid\`, \`relationship_type\`, \`verification_status\`
) VALUES
`;

const relValues = relationships.map(r => {
  return `('${r.source}', '${r.target}', '${r.type}', '${r.status}')`;
});

sql += relValues.join(',\n') + ';\n';

const seedSqlPath = path.join(__dirname, '../database/seed.sql');
fs.writeFileSync(seedSqlPath, sql, 'utf8');

// Summary stats
const layerCounts = {};
for (const c of citizens) {
  const year = parseInt(c.dob.substring(0, 4));
  let layer = birthYears.indexOf(year);
  if (layer === -1) {
    layer = birthYears.findIndex(y => y + 2 === year || y + 3 === year);
  }
  layerCounts[layer] = (layerCounts[layer] || 0) + 1;
}

console.log(`✅ Successfully generated 5-layer database!`);
console.log(`   Output: database/seed.sql (single source of truth)`);
console.log(`   Total citizens: ${citizens.length}`);
console.log(`   Total relationships: ${relationships.length}`);
console.log(`   Layer breakdown:`);
for (let l = 0; l <= 4; l++) {
  console.log(`     Layer ${l}: ${layerCounts[l] || 0} members`);
}
console.log(`   No sibling marriages enforced.`);

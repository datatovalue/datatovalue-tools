
// Parse the JSON string into an object
let jsonObj;
try {
jsonObj = JSON.parse(json_string);
} catch (e) {
return "Error parsing JSON: " + e.message;
}

// Function to create the tree
function buildTreeLines(obj, prefix = "", isLast = true, lines = [], path = ".") {
// Add the current node
if (prefix === "") {
    // Root node
    lines.push(path);
}

const entries = Object.entries(obj);

// Process each entry in the object
entries.forEach(([key, value], index) => {
    const isLastEntry = index === entries.length - 1;
    const newPrefix = prefix + (isLast ? "    " : "│   ");
    const connector = isLastEntry ? "└── " : "├── ";
    
    if (typeof value === 'object' && value !== null && !Array.isArray(value)) {
    // This is an object, always use colon
    lines.push(`${prefix}${connector}${key}:`);
    buildTreeLines(value, newPrefix, isLastEntry, lines, path + "/" + key);
    } else if (Array.isArray(value)) {
    // This is an array, always use colon
    lines.push(`${prefix}${connector}${key}:`);
    value.forEach((item, idx) => {
        const isLastItem = idx === value.length - 1;
        const arrayConnector = isLastItem ? "└── " : "├── ";
        
        if (typeof item === 'object' && item !== null) {
        // For array objects, also use colon
        lines.push(`${newPrefix}${arrayConnector}[${idx}]:`);
        buildTreeLines(item, newPrefix + (isLastItem ? "    " : "│   "), isLastItem, lines);
        } else {
        lines.push(`${newPrefix}${arrayConnector}[${idx}]: ${item}`);
        }
    });
    } else {
    // This is a primitive value
    lines.push(`${prefix}${connector}${key}: ${value}`);
    }
});

return lines;
}

// Build the tree and return it as a string
return buildTreeLines(jsonObj).join("\n");

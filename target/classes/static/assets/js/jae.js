// clean up any single quote escape charater in Json
function cleanUpJson(obj){
	const jsonString = JSON.stringify(obj, (key, value) => {
  		// If the value is a string, remove escape characters from it
  		if (typeof value === 'string') {
    		return value.replace(/'/g, '&#39;');
  		}
  			return value;
	});
	return jsonString;
}

// StringUtils.isNotBlank()
function isNotBlank(value) {
	return typeof value === 'string' && value.trim().length > 0;
}
 
// String escape characters : single/double quotes, linefeed
function encodeDecodeString(str) {
	// Encoding
	let encodedStr = str
	  .replace(/\\/g, '\\\\')    // Backslash
	  .replace(/'/g, "\\'")       // Single quote
	//   .replace(/"/g, '\\"')       // Double quote
	  .replace(/"/g, "\\'")       // Double quote to single quote
	  .replace(/\n/g, '\\n');     // Line feed
  
	// Decoding
	let decodedStr = encodedStr
	  .replace(/\\n/g, '\n')      // Line feed
	  .replace(/\\"/g, '"')       // Double quote
	  .replace(/\\'/g, "'")       // Single quote
	  .replace(/\\\\/g, '\\');    // Backslash
  
	return { encoded: encodedStr, decoded: decodedStr };
  }

// format date - ex> 15/07/2023
  function getFormattedToday() {
	var date = new Date();
	var day = date.getDate();
	var month = date.getMonth() + 1; // Months are zero-based
	var year = date.getFullYear();
  
	// Add leading zeros if necessary
	if (day < 10) {
	  day = '0' + day;
	}
	if (month < 10) {
	  month = '0' + month;
	}
  
	var formattedDate = day + '/' + month + '/' + year;
	return formattedDate;
  }

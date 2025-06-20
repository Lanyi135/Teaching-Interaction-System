/**
 * Validate username format
 * @param rule Validation rule (no special characters)
 * @param value The value to be validated
 * @param callback Callback function
 */
export const validateUsername = (rule, value, callback) => {
  var reg = /^[a-zA-Z0-9_\u4e00-\u9fa5]{1,16}$/;
  if (value.length > 16) {
    callback(new Error('Username cannot exceed 16 characters'));
  } else if (!reg.test(value)) {
    callback(new Error('Only English letters, Chinese characters, numbers and underscores are allowed'));
  } else {
    callback();
  }
};

/**
 * Validate password format
 * @param rule Validation rule (minimum 6 characters)
 * @param value The value to be validated
 * @param callback Callback function
 */
export const validatePassword = (rule, value, callback) => {
  if (value.length < 6) {
    callback(new Error('Password must be at least 6 characters long'));
  } else {
    callback();
  }
};

/**
 * Validate mobile phone number format
 * @param rule Validation rule
 * @param value The value to be validated
 * @param callback Callback function
 */
export const validateMobile = (rule, value, callback) => {
  var reg = /^[0-9][0-9][0-9]{9}$/;
  if (!reg.test(value)) {
    callback(new Error('Invalid mobile phone number format'));
  } else {
    callback();
  }
};

/**
 * Validate ID card number format
 * @param rule Validation rule (18 digits)
 * @param value The value to be validated
 * @param callback Callback function
 */
export const validateIDCard = (rule, value, callback) => {
  const reg = /^[1-9]\d{5}(18|19|([23]\d))\d{2}((0[1-9])|(10|11|12))(([0-2][1-9])|10|20|30|31)\d{3}[0-9Xx]$/;
  if (!reg.test(value)) {
    callback(new Error('Invalid ID card number format'));
  } else {
    callback();
  }
};

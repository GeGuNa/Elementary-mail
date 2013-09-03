/* Copyright 2011-2013 Yorba Foundation
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

// GLib's character-based substring function.
[CCode (cname = "g_utf8_substring")]
extern string glib_substring(string str, long start_pos, long end_pos);

namespace Geary.String {

public const char EOS = '\0';

public bool is_empty_or_whitespace(string? str) {
    return (str == null || str[0] == EOS || str.strip()[0] == EOS);
}

public inline bool is_empty(string? str) {
    return (str == null || str[0] == EOS);
}

public int count_char(string s, unichar c) {
    int count = 0;
    for (int index = 0; (index = s.index_of_char(c, index)) >= 0; ++index, ++count)
        ;
    return count;
}

public int ascii_cmp(string a, string b) {
    return strcmp(a, b);
}

public int ascii_cmpi(string a, string b) {
    char *aptr = a;
    char *bptr = b;
    for (;;) {
        int diff = (int) (*aptr).tolower() - (int) (*bptr).tolower();
        if (diff != 0)
            return diff;
        
        if (*aptr == EOS)
            return 0;
        
        aptr++;
        bptr++;
    }
}

public inline bool ascii_equal(string a, string b) {
    return ascii_cmp(a, b) == 0;
}

public inline bool ascii_equali(string a, string b) {
    return ascii_cmpi(a, b) == 0;
}

public uint stri_hash(string str) {
    return str_hash(str.down());
}

public uint nullable_stri_hash(string? str) {
    return (str != null) ? stri_hash(str) : 0;
}

public bool stri_equal(string a, string b) {
    return str_equal(a.down(), b.down());
}

public bool nullable_stri_equal(string? a, string? b) {
    if (a == null)
        return (b == null);
    
    // a != null, so always false
    if (b == null)
        return false;
    
    return stri_equal(a, b);
}

/**
 * Returns true if the string contains only whitespace and at least one numeric character.
 */
public bool is_numeric(string str) {
    bool numeric_found = false;
    unichar ch;
    int index = 0;
    while (str.get_next_char(ref index, out ch)) {
        if (ch.isdigit())
            numeric_found = true;
        else if (!ch.isspace())
            return false;
    }
    
    return numeric_found;
}

/**
 * Returns char from 0 to 9 converted to an int.  If a non-numeric value, -1 is returned.
 */
public inline int digit_to_int(char ch) {
    return ch.isdigit() ? (ch - '0') : -1;
}

public string uint8_to_hex(uint8[] buffer) {
    StringBuilder builder = new StringBuilder();
    
    bool first = true;
    foreach (uint8 byte in buffer) {
        if (!first)
            builder.append_c(' ');
        
        builder.append_printf("%X", byte);
        first = false;
    }
    
    return builder.str;
}

public string uint8_to_string(uint8[] buffer) {
    StringBuilder builder = new StringBuilder();
    foreach (uint8 byte in buffer)
        builder.append_printf("%c", (char) byte);
    
    return builder.str;
}

// Removes redundant spaces, tabs, and newlines.
public string reduce_whitespace(string _s) {
    string s = _s;
    s = s.replace("\n", " ");
    s = s.replace("\r", " ");
    s = s.replace("\t", " ");
    s = s.strip();
    
    // Condense multiple spaces to one.
    for (int i = 1; i < s.length; i++) {
        if (s.get_char(i) == ' ' && s.get_char(i - 1) == ' ') {
            s = s.slice(0, i - 1) + s.slice(i, s.length);
            i--;
        }
    }
    
    return s;
}

// Slices a string to, at most, max_length number of bytes (NOT including the null.)
// Due to the nature of UTF-8, it may be a few bytes shorter than the maximum.
//
// If the string is less than max_length bytes, it will be return unchanged.
public string safe_byte_substring(string s, ssize_t max_length) {
    if (s.length < max_length)
        return s;
    
    return glib_substring(s, 0, s.char_count(max_length));
}

}


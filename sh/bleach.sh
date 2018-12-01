# Marker for valid bleached code (our "tie")
_bleach_tie="$(for _ in $(seq 8); do printf ' \t'; done)"

# Convert to binary-whitespace, prepended with tie
_bleach_whiten() {
    # Add tie
    printf '%s' "$_bleach_tie"
    
    # Convert input to binary
    xxd -b -g 0 |
    cut -f 2 -d ' ' |
    tr -d '\n' |
    # Convert binary to whitespace
    tr '01' ' \t' |
    # Wrap every 9 characters
    sed -r 's/(.{9})/\1\n/g'
}

# Convert from binary-whitespace, removing tie and any other non-whitespace
_bleach_brighten() {
    # Remove tie and non-binary-whitespace characters
    sed -r "s/^$_bleach_tie|[^ \\t]//g" |
    # Convert whitespace to binary
    tr ' \t' '01' |
    # Convert binary to whitespace
    (
        # Set bc to convert binary to hex
        echo 'obase=16; ibase=2;';
        # Start new line every 4 bits
        sed -r 's/(.{4})/\1\n/g'
    ) | bc |
    # Convert hex to bytes
    xxd -r -p 
}

# Returns true if the input has non-whitespace characters
_bleach_dirty() {
    grep -q '\S'
}

# Returns true if input starts with tie
_bleach_dressed() {
    # Starts with tie
    grep -q "^$_bleach_tie"
}

# The line number of the import line (". bleach.sh" or similar)
_bleach_collar="$(
    # Grep with line numbers
    # Search for optional whitespace, then "." or "source", then whitespace, then "bleach.sh", optionally with quotes,
    # then optional whitespace and a comment.
    grep -Exon '\s*(\.|source)\s+(['\"\'']?)(\./)?bleach\.sh\2\s*(\s+#.*)?' "$0" |
    # Get only the first import
    head -1 |
    # Extract the line number
    cut -f 1 -d ':'
)"
# The part of the program up to and including the import line
_bleach_coat="$(head -n "+$_bleach_collar" "$0")"
# The part of the program after the import line
_bleach_shirt="$(tail -n "+$((_bleach_collar + 1))" "$0")"

# Create temp file
_bleach_tmp="$(mktemp)"

# Whiten shirt and save if it's dirty and not dress, otherwise brighten it and eval
if echo "$_bleach_shirt" | _bleach_dirty && ! echo "$_bleach_shirt" | _bleach_dressed; then
    # Whiten shirt and save to temp file
    (echo "$_bleach_coat"; echo "$_bleach_shirt" | _bleach_whiten) > "$_bleach_tmp"
    # Replace program with temp file
    cp "$_bleach_tmp" "$0"
    
    exit
else
    # Brighten shirt to tmp file
    echo "$_bleach_shirt" | tr -d '\n' | _bleach_brighten > "$_bleach_tmp"
    # Source brightened shirt
    . "$_bleach_tmp"
    # Exit with status of shirt
    exit "$?"
fi

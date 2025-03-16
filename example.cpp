#include <stdint.h>
#include <stdlib.h>
#include <string.h>

int parse_input(const uint8_t *data, size_t size) {
    if (size < 5) return 0; 
    
    if (memcmp(data, "FFFF", 4) != 0) return 0;
    
    char buf[32] = {0};
    size_t to_copy = size - 4 < 31 ? size - 4 : 30;
    memcpy(buf, data + 4, to_copy);
    
    int value = atoi(buf);
    if (value % 3 == 0) {
        return 1;
    }
    return 0;
}

extern "C" {
int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    parse_input(data, size);
    return 0;
}
}

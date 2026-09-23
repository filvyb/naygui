#define RAYGUI_IMPLEMENTATION
#include "raygui.h"

// Release allocations with the same allocator used by raygui.
void NayguiFree(void *ptr) { RAYGUI_FREE(ptr); }

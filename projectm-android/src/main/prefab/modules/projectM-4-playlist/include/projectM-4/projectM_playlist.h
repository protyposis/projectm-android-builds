#ifndef PROJECTM_PLAYLIST_H
#define PROJECTM_PLAYLIST_H

// Dummy header for local testing
// This will be replaced by actual projectM playlist headers in CI workflow

#ifdef __cplusplus
extern "C" {
#endif

void projectm_playlist_init(void);
void projectm_playlist_add(const char* item);
void projectm_playlist_cleanup(void);

#ifdef __cplusplus
}
#endif

#endif // PROJECTM_PLAYLIST_H

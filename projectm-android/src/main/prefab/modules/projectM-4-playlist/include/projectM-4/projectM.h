#ifndef PROJECTM_H
#define PROJECTM_H

// Dummy header for local testing
// This will be replaced by actual projectM headers in CI workflow

#ifdef __cplusplus
extern "C" {
#endif

void projectm_init(void);
void projectm_render(void);
void projectm_cleanup(void);

#ifdef __cplusplus
}
#endif

#endif // PROJECTM_H

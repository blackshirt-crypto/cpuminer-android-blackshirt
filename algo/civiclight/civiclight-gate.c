/*
 * civiclight-gate.c — CivicNet (CIVIC) mining algorithm for cpuminer-opt
 *
 * civiclight v2 hash pipeline:
 *   1. SHA256( block_header_80_bytes ) → hash1  (32 bytes)
 *   2. yespower_1.0( hash1, N=2048, r=8 ) → yp_out  (32 bytes)
 *   3. XOR( yp_out, hash1 ) → xor_buf  (32 bytes)
 *   4. SHA256( xor_buf ) → final_hash  (32 bytes)
 *
 * Blackshirt Crypto — blkshirtpool.com
 */

#include "algo-gate-api.h"
#include "algo/sha/sha256-hash.h"
#include "algo/yespower/yespower.h"

static yespower_params_t civiclight_yp_params;

int civiclight_hash( const char *input, char *output, int thrid )
{
    uint8_t hash1[32];
    uint8_t yp_raw[32];
    uint8_t xor_buf[32];

    // Step 1: SHA256 of the 80-byte block header
    sha256_full( hash1, input, 80 );

    // Step 2: yespower on the 32-byte SHA256 output
    if ( yespower_tls( (const uint8_t*)hash1, 32, &civiclight_yp_params,
                       (yespower_binary_t*)yp_raw, thrid ) )
        return 0;

    // Step 3: XOR yespower output with hash1
    for ( int i = 0; i < 32; i++ )
        xor_buf[i] = yp_raw[i] ^ hash1[i];

    // Step 4: final SHA256
    sha256_full( output, xor_buf, 32 );

    return 1;
}

int scanhash_civiclight( struct work *work, uint32_t max_nonce,
                         uint64_t *hashes_done, struct thr_info *mythr )
{
    uint32_t _ALIGN(64) vhash[8];
    uint32_t _ALIGN(64) endiandata[20];
    uint32_t *pdata = work->data;
    uint32_t *ptarget = work->target;
    const uint32_t first_nonce = pdata[19];
    const uint32_t last_nonce = max_nonce;
    uint32_t n = first_nonce;
    const int thr_id = mythr->id;

    memcpy( endiandata, pdata, 80 );

    do {
        if ( civiclight_hash( (char*)endiandata, (char*)vhash, thr_id ) )
        if unlikely( valid_hash( vhash, ptarget ) && !opt_benchmark )
        {
            be32enc( pdata+19, n );
            submit_solution( work, vhash, mythr );
        }
        endiandata[19] = ++n;
    } while ( n < last_nonce && !work_restart[thr_id].restart );

    *hashes_done = n - first_nonce;
    pdata[19] = n;
    return 0;
}

bool register_civiclight_algo( algo_gate_t* gate )
{
    civiclight_yp_params.version = YESPOWER_1_0;
    civiclight_yp_params.N       = 2048;
    civiclight_yp_params.r       = 8;
    civiclight_yp_params.pers    = NULL;
    civiclight_yp_params.perslen = 0;

    gate->optimizations = SSE2_OPT | SHA256_OPT | NEON_OPT;
    gate->scanhash      = (void*)&scanhash_civiclight;
    gate->hash          = (void*)&civiclight_hash;
    opt_target_factor   = 65536.0;

    applog( LOG_NOTICE, "Civiclight: SHA256 -> yespower(N=2048,r=8) -> XOR -> SHA256" );
    return true;
}

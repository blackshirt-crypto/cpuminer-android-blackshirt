/*
 * civiclight-gate.c — CivicNet (CIVIC) mining algorithm for cpuminer-opt
 *
 * civiclight v2 PoW hash pipeline (confirmed by NitroPool):
 *   1. SHA256d( block_header_80_bytes ) → intermediate  (32 bytes)
 *   2. SHA256( intermediate ) → hash1  (32 bytes)
 *   3. yespower_1.0( hash1, N=2048, r=8 ) → yp_out  (32 bytes)
 *   4. XOR( yp_out, hash1 ) → xor_buf  (32 bytes)
 *   5. SHA256( xor_buf ) → final_hash  (32 bytes)
 *
 * Blackshirt Crypto — blkshirtpool.com
 */

#include "algo-gate-api.h"
#include "algo/sha/sha256-hash.h"
#include "algo/yespower/yespower.h"

static yespower_params_t civiclight_yp_params;

static void civiclight_powhash( void *output, const void *header80, int thrid )
{
    uint8_t intermediate[32];
    uint8_t hash1[32];
    uint8_t yp_raw[32];
    uint8_t xor_buf[32];

    // Step 1: SHA256d of the 80-byte header
    sha256_full( intermediate, header80, 80 );
    sha256_full( intermediate, intermediate, 32 );

    // Step 2: SHA256 of the intermediate
    sha256_full( hash1, intermediate, 32 );

    // Step 3: yespower on hash1
    if ( yespower_tls( (const uint8_t*)hash1, 32, &civiclight_yp_params,
                       (yespower_binary_t*)yp_raw, thrid ) )
    {
        memset( output, 0xff, 32 );
        return;
    }

    // Step 4: XOR yespower output with hash1
    for ( int i = 0; i < 32; i++ )
        xor_buf[i] = yp_raw[i] ^ hash1[i];

    // Step 5: final SHA256
    sha256_full( output, xor_buf, 32 );
}

int civiclight_hash( const char *input, char *output, int thrid )
{
    civiclight_powhash( output, input, thrid );
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

    for ( int k = 0; k < 19; k++ )
        be32enc( &endiandata[k], pdata[k] );

    do {
        endiandata[19] = n;
        civiclight_powhash( vhash, endiandata, thr_id );
        if unlikely( valid_hash( vhash, ptarget ) && !opt_benchmark )
        {
            pdata[19] = bswap_32( n );
            submit_solution( work, vhash, mythr );
        }
        n++;
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

    gate->optimizations = SSE2_OPT | AVX2_OPT | AVX512_OPT | NEON_OPT;
    gate->scanhash      = (void*)&scanhash_civiclight;
    gate->hash          = (void*)&civiclight_hash;

    applog( LOG_NOTICE, "Civiclight: SHA256d -> SHA256 -> yespower(N=2048,r=8) -> XOR -> SHA256" );
    return true;
}

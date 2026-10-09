// Offline test renderer for the pond engine (no Max needed).
//   render out.wav [scenario]
// Scenarios: melody (default), chord, sweep, cpu
#include "../source/engine/pond_engine.h"
#include <chrono>
#include <cstdio>
#include <string>
#include <vector>

static void writeWav(const char* path, const std::vector<float>& L, const std::vector<float>& R, int sr) {
    FILE* f = std::fopen(path, "wb");
    if (!f) { std::perror(path); return; }
    uint32_t n = (uint32_t)L.size(), dataBytes = n * 2 * 4;
    auto u32 = [&](uint32_t v) { std::fwrite(&v, 4, 1, f); };
    auto u16 = [&](uint16_t v) { std::fwrite(&v, 2, 1, f); };
    std::fwrite("RIFF", 1, 4, f); u32(36 + dataBytes); std::fwrite("WAVEfmt ", 1, 8, f);
    u32(16); u16(3); u16(2); u32(sr); u32(sr * 8); u16(8); u16(32);
    std::fwrite("data", 1, 4, f); u32(dataBytes);
    for (uint32_t i = 0; i < n; i++) { std::fwrite(&L[i], 4, 1, f); std::fwrite(&R[i], 4, 1, f); }
    std::fclose(f);
}

struct Ev { double t; int note, vel; };

int main(int argc, char** argv) {
    const char* out = argc > 1 ? argv[1] : "render.wav";
    std::string sc = argc > 2 ? argv[2] : "melody";
    const int sr = 44100, block = 64;
    pond::Engine eng;
    eng.rebuild();
    std::vector<Ev> evs; double len = 8.0;
    if (sc == "melody") {
        int notes[] = {48, 51, 55, 58, 60, 55}; double d[] = {0.7, 0.7, 0.7, 0.7, 1.2, 2.4}; double t = 0.1;
        for (int i = 0; i < 6; i++) { evs.push_back({t, notes[i], 100}); evs.push_back({t + d[i] - 0.05, notes[i], 0}); t += d[i]; }
        len = t + 1.0;
    } else if (sc == "chord") {
        for (int nn : {48, 55, 63}) { evs.push_back({0.1, nn, 100}); evs.push_back({5.0, nn, 0}); }
        len = 6.5;
    } else if (sc == "sweep") {
        int notes[] = {36, 48, 60, 72}; double t = 0.1;
        for (int nn : notes) { evs.push_back({t, nn, 100}); evs.push_back({t + 2.3, nn, 0}); t += 2.6; }
        len = t + 0.5;
    } else if (sc == "user" || sc == "userstatic") {
        // settings from the first Live test screenshot
        eng.prm.corners = 6.7f; eng.prm.walls = -0.9f; eng.prm.visc = 0.f; eng.prm.refl = 1.f;
        eng.prm.speed = 0.63f; eng.prm.wander = sc == "user" ? 0.61f : 0.f; eng.prm.width = 0.5f;
        eng.prm.detune = 6.f; eng.prm.drift = 0.82f; eng.prm.release = 3460.f; eng.prm.volume = -6.f;
        eng.rebuild();
        double t = 0.1;
        for (int nn : {48, 51, 55, 60, 58, 55}) { evs.push_back({t, nn, 100}); evs.push_back({t + 0.9, nn, 0}); t += 1.0; }
        len = t + 2.0;
    } else if (sc == "visc") {
        double t = 0.1;
        for (float v : {0.f, 0.25f, 0.5f, 0.75f, 0.9f, 1.f}) { (void)v; evs.push_back({t, 48, 100}); evs.push_back({t + 2.0, 48, 0}); t += 2.6; }
        len = t;
    } else if (sc == "cpu") {
        // worst case: 4 high notes, key tracking at its 4x cap, strong current
        eng.prm.current = 0.8f; eng.prm.speed = 1.f; eng.rebuild();
        for (int nn : {72, 76, 79, 84}) evs.push_back({0.0, nn, 100});
        len = 10.0;
    }
    size_t N = (size_t)(len * sr);
    std::vector<float> L(N), R(N);
    size_t ei = 0; std::sort(evs.begin(), evs.end(), [](const Ev& a, const Ev& b) { return a.t < b.t; });
    auto t0 = std::chrono::steady_clock::now();
    for (size_t pos = 0; pos < N; pos += block) {
        double now = (double)pos / sr;
        while (ei < evs.size() && evs[ei].t <= now) {
            if (sc == "visc" && evs[ei].vel > 0) {
                static int k = 0; const float vs[] = {0.f, 0.25f, 0.5f, 0.75f, 0.9f, 1.f};
                eng.prm.visc = vs[std::min(k++, 5)]; eng.rebuild();
            }
            eng.noteOn(evs[ei].note, evs[ei].vel); ei++;
        }
        int n = (int)std::min<size_t>(block, N - pos);
        eng.process(&L[pos], &R[pos], n, sr);
    }
    double secs = std::chrono::duration<double>(std::chrono::steady_clock::now() - t0).count();
    float peak = 0; double ss = 0;
    for (size_t i = 0; i < N; i++) { peak = std::max(peak, std::max(std::fabs(L[i]), std::fabs(R[i]))); ss += L[i] * L[i]; }
    std::printf("%s: %.1f s audio in %.2f s -> %.1f%% of one core | peak %.3f | rms %.4f\n",
                sc.c_str(), len, secs, 100.0 * secs / len, peak, std::sqrt(ss / N));
    // rebuild cost (main thread)
    auto r0 = std::chrono::steady_clock::now();
    eng.prm.start = 2.0f; eng.rebuild();
    std::printf("rebuild with start=2.0 s: %.1f ms\n", 1000 * std::chrono::duration<double>(std::chrono::steady_clock::now() - r0).count());
    writeWav(out, L, R, sr);
    return 0;
}

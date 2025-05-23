package rlutil

import "core:time"

CLOCK_H_M_S_MS :: "%02vh:%02vm:%02vs.%03vms"
CLOCK_H_M      :: "%02vh:%02vm"
CLOCK_M_S      :: "%02vm:%02vs"
CLOCK_S_MS     :: "%02vs.%03vms"

_time_abs :: proc "contextless" (t: time.Time) -> u64 {
    return u64(t._nsec/1e9 + time.UNIX_TO_ABSOLUTE)
}

clock_from_nano :: proc "contextless" (nsec: i64) -> (hour, min, sec, ms: int) {
    ms = int(nsec / 1_000_000)

    sec = ms / 1000;
    ms %= 1000;

    min = sec / 60;
    sec %= 60;

    hour = min / 60;
    min %= 60;
    return
}

clock_from_nano_ex :: proc "contextless" (nsec: i64) -> (day, hour, min, sec, ms: int) {
    hour, min, sec, ms = clock_from_nano(nsec)
    day = hour / 24
    hour %= 24
    return
}

MIN_HMSMS_LEN :: 12
time_to_hmsms :: proc(t: i64, buf: []u8) -> (res: string) #no_bounds_check {
    assert(len(buf) >= MIN_HMSMS_LEN)
    h, m, s, ms := clock_from_nano(t)

    buf[11] = '0' + u8(ms % 10); ms /= 10
    buf[10] = '0' + u8(ms % 10); ms /= 10
    buf[9] =  '0' + u8(ms)
    buf[8] = '.'

    buf[7] = '0' + u8(s % 10); s /= 10
    buf[6] = '0' + u8(s)
    buf[5] = ':'
    buf[4] = '0' + u8(m % 10); m /= 10
    buf[3] = '0' + u8(m)
    buf[2] = ':'
    buf[1] = '0' + u8(h % 10); h /= 10
    buf[0] = '0' + u8(h)
    defer delete(buf)
    return string(buf[:MIN_HMSMS_LEN]) // len HMSMS
}
#!/bin/bash

for r in {0..255..8}; do
    for g in {0..255..8}; do
        # 这里的 48;2;%d;%d;%dm 就是 TrueColor 的标准格式
        # 我们用红色(r)和绿色(g)做渐变，蓝色(b)固定为 128
        printf "\e[48;2;%d;%d;128m " "$r" "$g"
    done
    printf "\e[0m\n"
done


#!/bin/env python3
# coding: utf-8

from collections import Counter

def main():
    ips = list()
    with open('ip_list') as f:
        for ip in f.readlines():
            ips.append(ip.strip())

    #print (len(x))
    counts = Counter(ips)

    for count in counts:
        if counts[count] > 500:
            print (count)


if __name__ == "__main__":
    main()

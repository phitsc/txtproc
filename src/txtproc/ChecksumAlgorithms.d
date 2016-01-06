module txtproc.checksum_algorithms;

import std.digest.crc : CRC32, crcHexString;
import std.digest.md : MD5;
import std.digest.ripemd : RIPEMD160;
import std.digest.sha;
import std.string : format;

import txtproc.algorithms;
import txtproc.textalgo;

class ChecksumAlgorithms : Algorithms
{
    this()
    {
        add(new Algorithm(
            "CRC32", "Checksum", "Calculate CRC of input text.", [],
            (string text, string[], bool) {
                return crcHexString(digest!CRC32(text)).dup.text;
            }
        ));

        add(new Algorithm(
            "MD5", "Checksum", "Calculate MD5 of input text.", [],
            (string text, string[], bool) {
                return toHexString(digest!MD5(text)).dup.text;
            }
        ));

        add(new Algorithm(
            "RIPEMD160", "Checksum", "Calculate RIPEMD160 of input text.", [],
            (string text, string[], bool) {
                return toHexString(digest!RIPEMD160(text)).dup.text;
            }
        ));

        add(new Algorithm(
            "SHA1", "Checksum", "Calculate SHA1 of input text.", [],
            (string text, string[], bool) {
                return toHexString(digest!SHA1(text)).dup.text;
            }
        ));

        add(new Algorithm(
            "SHA256", "Checksum", "Calculate SHA-256 of input text.", [],
            (string text, string[], bool) {
                return toHexString(digest!SHA256(text)).dup.text;
            }
        ));

        add(new Algorithm(
            "SHA512", "Checksum", "Calculate SHA-512 of input text.", [],
            (string text, string[], bool) {
                return toHexString(digest!SHA512(text)).dup.text;
            }
        ));

        add(new Algorithm(
            "Checksum", "Checksum", "Calculate all available checksums of input text.", [],
            (string text, string[], bool) {
                string result;

                result ~= format("    CRC 32 : %s", crcHexString(digest!CRC32    (text))) ~ newline;
                result ~= format("       MD5 : %s", crcHexString(digest!MD5      (text))) ~ newline;
                result ~= format("RIPEMD-160 : %s", crcHexString(digest!RIPEMD160(text))) ~ newline;
                result ~= format("      SHA1 : %s", crcHexString(digest!SHA1     (text))) ~ newline;
                result ~= format("   SHA-256 : %s", crcHexString(digest!SHA256   (text))) ~ newline;
                result ~= format("   SHA-512 : %s", crcHexString(digest!SHA512   (text)));

                return result;
            }
        ));
    }
}

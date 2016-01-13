module txtproc.checksum_algorithms;

import std.digest.crc : CRC32, crcHexString;
import std.digest.md : MD5;
import std.digest.ripemd : RIPEMD160;
import std.digest.sha;

import txtproc.algorithms;
import txtproc.lineendings;
import txtproc.textalgo;

class ChecksumAlgorithms : Algorithms
{
    this()
    {
        add(new Algorithm(
            "CRC32", "Checksum", "Calculate CRC of input text.", [
                ParameterDescription("Change line endings before processing - d[ontChange], u[nix], w[indows]", Default("dontChange")),
            ],
            (string text, string[] params, bool) {
                return crcHexString(digest!CRC32(changeLineEndings(text, params[0]))).dup.text;
            }
        ));

        add(new Algorithm(
            "MD5", "Checksum", "Calculate MD5 of input text.", [
                ParameterDescription("Change line endings before processing - d[ontChange], u[nix], w[indows]", Default("dontChange")),
            ],
            (string text, string[] params, bool) {
                return toHexString(digest!MD5(changeLineEndings(text, params[0]))).dup.text;
            }
        ));

        add(new Algorithm(
            "RIPEMD160", "Checksum", "Calculate RIPEMD160 of input text.", [
                ParameterDescription("Change line endings before processing - d[ontChange], u[nix], w[indows]", Default("dontChange")),
            ],
            (string text, string[] params, bool) {
                return toHexString(digest!RIPEMD160(changeLineEndings(text, params[0]))).dup.text;
            }
        ));

        add(new Algorithm(
            "SHA1", "Checksum", "Calculate SHA1 of input text.", [
                ParameterDescription("Change line endings before processing - d[ontChange], u[nix], w[indows]", Default("dontChange")),
            ],
            (string text, string[] params, bool) {
                return toHexString(digest!SHA1(changeLineEndings(text, params[0]))).dup.text;
            }
        ));

        add(new Algorithm(
            "SHA256", "Checksum", "Calculate SHA-256 of input text.", [
                ParameterDescription("Change line endings before processing - d[ontChange], u[nix], w[indows]", Default("dontChange")),
            ],
            (string text, string[] params, bool) {
                return toHexString(digest!SHA256(changeLineEndings(text, params[0]))).dup.text;
            }
        ));

        add(new Algorithm(
            "SHA512", "Checksum", "Calculate SHA-512 of input text.", [
                ParameterDescription("Change line endings before processing - d[ontChange], u[nix], w[indows]", Default("dontChange")),
            ],
            (string text, string[] params, bool) {
                return toHexString(digest!SHA512(changeLineEndings(text, params[0]))).dup.text;
            }
        ));

        add(new Algorithm(
            "Checksum", "Checksum", "Calculate all available checksums of input text.", [
                ParameterDescription("Change line endings before processing - d[ontChange], u[nix], w[indows]", Default("dontChange")),
            ],
            (string text, string[] params, bool) {
                import std.string : format;

                const temp = changeLineEndings(text, params[0]);

                string result;

                result ~= format("    CRC 32 : %s", crcHexString(digest!CRC32    (temp))) ~ newline;
                result ~= format("       MD5 : %s", toHexString (digest!MD5      (temp))) ~ newline;
                result ~= format("RIPEMD-160 : %s", toHexString (digest!RIPEMD160(temp))) ~ newline;
                result ~= format("      SHA1 : %s", toHexString (digest!SHA1     (temp))) ~ newline;
                result ~= format("   SHA-256 : %s", toHexString (digest!SHA256   (temp))) ~ newline;
                result ~= format("   SHA-512 : %s", toHexString (digest!SHA512   (temp)));

                return result;
            }
        ));
    }
}

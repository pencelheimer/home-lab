{...}: {
  flake.nixosModules.security = {
    lib,
    config,
    ...
  }: {
    # Partial mitigation for the eMudhra Intermediate CA compromise
    # (CVE-2026-111943) until nixpkgs ships a cacert >= 3.127 with the
    # distrust applied. These two roots are blacklisted system-wide.
    # Remove once cacert is bumped and this is no longer needed.
    security.pki.caCertificateBlacklist = [
      "Comodo AAA Services root"
      "emSign ECC Root CA - G3"
    ];
  };
}
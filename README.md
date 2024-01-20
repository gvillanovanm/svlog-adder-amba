# AES IP - Encryption/Decryption

This repository contains the implementation of an AES (Advanced Encryption Standard) IP with an AMBA AXI4-Lite interface. The IP is developed using SystemVerilog and supports various modes of operation, including ECB, CBC, PCBC, CFB, OFB, and CTR. The architecture of the IP is designed to work with 128-bit data.

## Project Overview

The AES IP project aims to provide a reliable and efficient solution for encryption and decryption operations using the AES algorithm. The IP incorporates an AMBA AXI4-Lite interface, allowing easy integration into larger systems. The SystemVerilog language is used for the design and implementation of the IP, ensuring modularity and maintainability.

## Modes of Operation

The AES IP supports the following modes of operation:

- Electronic Codebook (ECB)
- Cipher Block Chaining (CBC)
- Propagating Cipher Block Chaining (PCBC)
- Cipher Feedback (CFB)
- Output Feedback (OFB)
- Counter (CTR)

These modes offer different levels of security and functionality, allowing flexibility in addressing various application requirements.

## Usage

To use the AES IP in your project, follow these steps:

1. Clone the repository to your local machine.
2. Integrate the `aes_ip.sv` module into your SystemVerilog project.
3. Connect the AMBA AXI4-Lite interface signals to your system bus.
4. Instantiate and connect the AES IP module in your design.
5. Simulate, synthesize, and verify the integration with your test environment.

Detailed usage instructions, including the interface specifications and configuration options, can be found in the project documentation.

## Contributing

Contributions to this project are welcome. If you encounter any issues, have suggestions, or would like to contribute enhancements, please submit a pull request. Please ensure that your contributions align with the project's coding standards and guidelines.

## License

TODO.

## Acknowledgments

This project was developed as part of the Embedded Lab - UFCG (https://www.embedded.ufcg.edu.br/). Special thanks to the instructors and contributors for their guidance and support.

Please refer to the documentation for further details and contact information.

Enjoy using the AES IP for your encryption and decryption needs!
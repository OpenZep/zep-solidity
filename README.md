# <img src="logo.png" alt="OpenZeppelin" width="400px">

[![NPM Package](https://img.shields.io/npm/v/openzeppelin-solidity.svg?style=flat-square)](https://www.npmjs.org/package/openzeppelin-solidity)
[![Build Status](https://img.shields.io/travis/OpenZeppelin/openzeppelin-solidity.svg?branch=master&style=flat-square)](https://travis-ci.org/OpenZeppelin/openzeppelin-solidity)
[![Coverage Status](https://img.shields.io/coveralls/github/OpenZeppelin/openzeppelin-solidity/master.svg?style=flat-square)](https://coveralls.io/github/OpenZeppelin/openzeppelin-solidity?branch=master)

*OpenZeppelin is a library for secure smart contract development.* It provides implementations of standards like ERC20 and ERC721 which you can deploy as-is or extend to suit your needs, as well as Solidity components to build custom contracts and more complex decentralized systems.

## Install

```
npm install openzeppelin-solidity
```

## Usage

To write your custom contracts, import ours and extend them through inheritance.

```solidity
import 'openzeppelin-solidity/contracts/token/ERC721/ERC721.sol';
import 'openzeppelin-solidity/contracts/token/ERC721/ERC721Mintable.sol';

contract MyNFT is ERC721, ERC721Mintable {
}
```

> You need to be using a framework like Truffle or Embark for the above import statements to work! Check out these guides.

You can find the API documentation [online][API docs]. Keep in mind that it’s a work in progress, and don’t hesitate to ask questions in [our Slack][Slack].

## Security

OpenZeppelin the project is maintained by [Zeppelin] the company, and developed following our high standards for code quality and security. OpenZeppelin is meant to provide tested and community-audited code, but please use common sense when doing anything that deals with real money! We take no responsibility for your implementation decisions and any security problems you might experience.

The core development principles and strategies that OpenZeppelin is based on include: security in depth, simple and modular code, clarity-driven naming conventions, comprehensive unit testing, pre-and-post-condition sanity checks, code consistency, and regular audits.

Please report any security issues you find to security@openzeppelin.org.

## Contribute

OpenZeppelin exists thanks to its contributors. There are many ways you can participate and help build high quality software. Check out the contribution guide!

## License

OpenZeppelin is released under the [MIT License](LICENSE).


[API docs]: https://openzeppelin.org/api/docs/token_ERC721_ERC721BasicToken.html
[Slack]: https://slack.openzeppelin.org
[Zeppelin]: https://zeppelin.solutions

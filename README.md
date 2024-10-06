# Shared-Wallet
This is a regular wallet, to which you can deposit and withdraw funds, but, compared to regular wallets, it has a special feature: the ability to share access. So, this wallet has an owner (the one who placed the contract), as well as an unlimited number of users. The owner will be able to withdraw any amount of money, and users - only amounts within the established limit. Only the owner will be able to create users and set a limit for them.

Such a wallet can be relevant, for example, for paying remuneration to project participants, where the project leader is also the owner of the wallet.

It is built using external features of OpenZeppelin.

These contracts contain the following functions:
- Create a new user (owner only);
- Give administrator rights (owner only);
- Take away administrator rights (owner only);
- Add or change user limit (owner only);
- Delete user (owner only);
- Check: is the transaction initiator the owner;
- Check: the initiator is the owner or user, the transaction does not exceed the limit;
- Withdrawal function;
- Fallback and receive protective functions.

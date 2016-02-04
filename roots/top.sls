base:
    '*':
        - salt.minion
    'salt':
        - salt.master
        - salt.formulas
        - salt.api
        
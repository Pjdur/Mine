import re

class MineInterpreter:
    def __init__(self):
        self.variables = {}

    def parse(self, code):
        lines = code.split('\n')
        for line in lines:
            self.execute(line.strip())

    def execute(self, line):
        if line.startswith('print'):
            self.handle_print(line)
        elif '=' in line:
            self.handle_assignment(line)
        else:
            print(f"Syntax error: {line}")

    def handle_print(self, line):
        match = re.match(r'print\s*\((.*)\)', line)
        if match:
            expression = match.group(1).strip()
            value = self.evaluate_expression(expression)
            print(value)
        else:
            print(f"Syntax error: {line}")

    def handle_assignment(self, line):
        parts = line.split('=')
        if len(parts) == 2:
            variable = parts[0].strip()
            expression = parts[1].strip()
            value = self.evaluate_expression(expression)
            self.variables[variable] = value
        else:
            print(f"Syntax error: {line}")

    def evaluate_expression(self, expression):
        try:
            return eval(expression, {}, self.variables)
        except Exception as e:
            print(f"Evaluation error: {e}")
            return None

int cursor = 0;
char color = 0x07;

char cmd[64];
char a[16];
char b[16];
char buffer[16];
char name[16];
char n[16];
int i, j, r, c, result, rows;

void putInMemory(int segment, int address, char character);
int getChar();

// 1. printChar()
void printChar(char c) {
    putInMemory(0xB800, cursor * 2, c);
    putInMemory(0xB800, cursor * 2 + 1, color);
    cursor++;
}

// 2. printString()
void printString(char *str) {
    int i = 0;
    while (str[i] != '\0') {
       printChar(str[i]);
       i++;
    }
}

void newline() {
    int column = cursor;
    while (column >= 80) column -= 80;
    cursor = cursor + (80 - column);
}

// 3. clearScreen()
void clearScreen() {
    int i;
    for (i = 0; i < 2000; i++) {
        putInMemory(0xB800, i * 2, ' ');
        putInMemory(0xB800, i * 2 + 1, color);
    }
    cursor = 0;
}

// 4. readString()
void readString(char *buffer) {
    int i = 0;
    char c;
    while (1) {
        c = getChar();
        if (c == '\r') {
            buffer[i] = '\0';
            break;
        }
        else if (c == '\b' && i > 0) {
         i--;
         cursor--;
         putInMemory(0xB800, cursor * 2, ' ');
       }
       else
       {
         buffer[i] = c;
         printChar(c);
         i++;
       }
    }
}

// 5. strcmp()
int strcmp(char *str1, char *str2) {
    int i = 0;
    while (str1[i] != '\0' && str2[i] != '\0') {
       if (str1[i] != str2[i]) return 0;
       i++;
    }
    return str1[i] == '\0' && str2[i] == '\0';
}

// 6. startsWith()
int startsWith(char *str, char *prefix) {
    int i = 0;
    while (prefix[i] != '\0') {
       if (str[i] != prefix[i]) return 0;
       i++;
    }
    return 1;
}

// 7. atoi()
int atoi(char *str) {
    int result = 0;
    int i = 0;
    int neg = 0;
    if (str[0] == '-') {
        neg = 1;
        i = 1;
    }
    while (str[i] >= '0' && str[i] <= '9') {
       result = result * 10 + (str[i] - '0');
       i++;
    }
    if (neg) return -result;
    return result;
}

// 8. intToString()
void intToString(int n, char *buffer) {
   int i = 0;
   int j = 0;
   int neg = 0;
   int digit;
   int q;
   char temp[16];
   if (n == 0) {
      buffer[0] = '0';
      buffer[1] = '\0';
      return;
   }
   if (n < 0) {
      neg = 1;
      n = -n;
   }
   while (n > 0) {
      digit = n;
      q = 0;
      while (digit >= 10) {
        digit -= 10;
        q++;
      }
      temp[i++] = '0' + digit;
      n = q;
   }
   if (neg) buffer[j++] = '-';
   while (i > 0) buffer[j++] = temp[--i];
   buffer[j] = '\0';
}

// 9. factorial()
int factorial(int n) {
    int result = 1;
    int i;
    if (n == 0 || n == 1) return 1;
    for (i = 2; i <= n; i++) {
        result = result * i;
        if (result < 0) return -1;
    }
    return result;
}

void main() {
    clearScreen();

    printString("Welcome to <X>");
    newline();

    printString("type 'help'");
    newline();
    newline();

    while (1) {

        printString("> ");

        readString(cmd);

        newline();

        if (strcmp(cmd, "check")) {
            printString("ok");
        } else if (strcmp(cmd, "help")) {
            printString("check add sub fac season triangle clear about");
        } else if (strcmp(cmd, "clear")) {
            clearScreen();
        } else if (startsWith(cmd, "add ")) {
            i = 4;
            j = 0;
            while (cmd[i] != ' ' && j < 15) {
                a[j++] = cmd[i++];
            }
            a[j] = '\0';
            i++;
            j = 0;
            while (cmd[i] != '\0') {
                b[j++] = cmd[i++];
            }
            b[j] = '\0';
            result = atoi(a) + atoi(b);
            intToString(result, buffer);
            printString(buffer);

        } else if (startsWith(cmd, "sub ")) {
            i = 4;
            j = 0;
            while (cmd[i] != ' ' && j < 15) {
                 a[j++] = cmd[i++];
            }
            a[j] = '\0';
            i++;
            j = 0;

            while (cmd[i] != '\0') {
                b[j++] = cmd[i++];
            }
            b[j] = '\0';
            result = atoi(a) - atoi(b);
            intToString(result, buffer);
            printString(buffer);
         } else if (startsWith(cmd, "fac ")) {
            i = 4;
            j = 0;
            while (cmd[i] != '\0') n[j++] = cmd[i++];
            n[j] = '\0';
            result = factorial(atoi(n));
            if (result == -1) {
                printString("know your limit little bro.");
            } else {
                intToString(result, buffer);
                printString(buffer);
            }
         } else if (startsWith(cmd, "season ")) {
            i = 7;
            j = 0;
            while (cmd[i] != '\0') name[j++] = cmd[i++];
            name[j] = '\0';
            if (strcmp(name, "winter")) {
               color = 0x01; // blue
               printString("winter mode");
            } else if (strcmp(name, "spring")) {
               color = 0x02; // green
               printString("spring mode");
            } else if (strcmp(name, "summer")) {
               color = 0x0E; // yellow
               printString("summer mode");
            } else if (strcmp(name, "fall")) {
               color = 0x06; // orange/brown
               printString("fall mode");
            } else if (strcmp(name, "radiant")) {
               color = 0x0D; // pink
               printString("radiant mode");
            }
         } else if (startsWith(cmd, "triangle ")) {
            i = 9;
            j = 0;
            while (cmd[i] != '\0') n[j++] = cmd[i++];
            n[j] = '\0';
            rows = atoi(n);
            for (r = 1; r <= rows; r++) {
               for (c = 0; c < r; c++) {
                  printChar('x');
               }
               newline();
            }
         } else if (strcmp(cmd, "about")) {
            printString("Assistant's Last Gift");
            newline();
	    printString("Final Challenge has ended~!");
         }
         newline();
    }
}

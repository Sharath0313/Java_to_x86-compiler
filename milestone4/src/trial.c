#include <stdio.h>

int add(int a, int b){

    int c;
    c = a+b;
    // printf("%d ",c);
    return c;

}

void main(){
    int a=0, b=1;
    int c=3, d=4,e=9;
    c = add(b,d);
    printf("%d %d %d %d %d\n",a,b,c,d,e);

    return ;
}
/**
 * Java 1 Homework 2
 *
 * @authors Sergey Leschenko
 * @version dated Jul 14, 2018
 */
class Java1Homework2 {

    public static void main(String[] args) {

        int i = 0;
        int[] n1 = { 1, 1, 0, 0, 1, 0, 1, 1,0, 0};
        while(i < n1.length){
            if(n1[i] == 0){n1[i] = 1;}
            System.out.print(n1[i] + " ");
            i++;
        }

        System.out.println("");






        i = 0;
        int j = 0;
        int[] n2 = new int[8];
        while(i != n2.length){
            n2[i] = j;
            System.out.print(n2[i] + " ");
            i++;
            j += 3;
        }

        System.out.println("");






        i = 0;
        int[] n3 = {1, 5, 3, 2, 11, 4, 5, 2, 4, 8, 9, 1};
        while(i < n3.length){
            if(n3[i] < 6){n3[i] = n3[i] * 2;}
            System.out.print(n3[i] + " ");
            i++;
        }

        System.out.println("");






        i = 0;
        int[] n5 = {1, 5, 3, 2, 11, 4, 5, 2, 4, 8, 9, 1};
        int min = n5[0];
        int max = n5[0];
        while(i < n5.length){
            if(n5[i] < min){min = n5[i];}
            if(n5[i] > max){max = n5[i];}
            i++;
        }
        System.out.println("Минимальный - " + min + "  ||  Максимальный - " + max);





        i = 0;
        j = 0;
        int r = 5;
        int[][] n4 = new int[r][r];
        while(i < r){
            j = 0;
            while(j < r){
                if(i == j){n4[i][j] = 1;}
                if(r - j - 1 == i){n4[i][j] = 1;}
                System.out.print(n4[i][j] + " ");
                j++;
            }
            System.out.println("");
            i++;
        }





        int[] n6 = {1,2,3,4,5,6,4,8,9};
        System.out.println(number6(n6));






        int[] n7 = {1,2,3,4,5,6,7,8,9};
        int n = -5;
        number7(n7, n);
        i = 0;
        while(i != n7.length) {
            System.out.print(n7[i] + " ");
            i++;
        }
        System.out.println("");





    }

    static boolean number6(int[] n6){
        int i = 0;
        boolean summa = false;
        while(i < n6.length){
            int j = 0;
            int sum1 = 0;
            int sum2 = 0;
            while(j < n6.length){
                if(j <= i){sum1 +=n6[j];}
                else{sum2 += n6[j];}
                j++;
            }
            if(sum1 == sum2){summa = true;}
            i++;
        }
        return(summa);
    }




    static void number7(int[] n7, int n){
        int j1 = 0;
        int j2 = 0;
        while(j1 != n && j2 != n) {
            if(n > 0) {
                int k1 = 0;
                int k2 = n7[0];
                int i = 0;
                while (i < n7.length) {
                    if (i != n7.length - 1) {
                        k1 = n7[i + 1];
                        n7[i + 1] = k2;
                        k2 = k1;
                    } else {
                        n7[0] = k2;
                    }
                    i++;
                }
            }
            else{
                int k1 = 0;
                int k2 = n7[n7.length - 1];
                int i = n7.length - 1;
                while (i >= 0) {
                    if (i != 0) {
                        k1 = n7[i - 1];
                        n7[i - 1] = k2;
                        k2 = k1;
                    } else {
                        n7[n7.length - 1] = k2;
                    }
                    i--;
                }
            }
            j2--;
            j1++;
        }

    }
}

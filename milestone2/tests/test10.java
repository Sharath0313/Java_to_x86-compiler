public int calculateSum(Node temp){  
        int sum, sumLeft, sumRight;  
        sum = sumRight = sumLeft = 0;  
  
        //Check whether tree is empty  
        if(root == null) {  
            System.out.println("Tree is empty");  
            return 0;  
        }  
        else {  
            //Calculate the sum of nodes present in left subtree  
            if(temp.left != null)  
                sumLeft = calculateSum(temp.left);  
  
            //Calculate the sum of nodes present in right subtree  
            if(temp.right != null)  
                sumRight = calculateSum(temp.right);  
  
            //Calculate the sum of all nodes by adding sumLeft, sumRight and root node's data  
            sum = temp.data + sumLeft + sumRight;  
            return sum;  
        }  
      }  

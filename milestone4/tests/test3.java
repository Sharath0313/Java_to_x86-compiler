public class Student   {  
	private int roll;  
	public int getRoll(){  
		return roll;  
	}  
	public void setRoll(int r) {  
		roll = r;  
	}  
	public void display(){  
		System.out.println(roll);  
	}  
}  
class Main {
	public static void main(String args[]){
		Student s = new Student();
		s.setRoll(200477);
		s.setRoll(s.getRoll() + 439);
		s.display();
        return ;
	}
}
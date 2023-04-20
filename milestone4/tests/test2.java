class Circle{
	public int radius;
	public int diameter;
	Circle(int r){radius = r+0;}
}
class Main {
	public static void main(String args[])
	{
		Circle c = new Circle(5);
		c.diameter = c.radius*2 ;
		System.out.println(c.radius);
		System.out.println(c.diameter);
        return ;
	}
}

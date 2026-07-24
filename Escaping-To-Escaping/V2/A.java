public class A {
    static {
        try {
            Class.forName("A");
            Class.forName("Bees");
            Class.forName("C");
        } catch (Exception e) {}
    }
    public static void main(String[] args) {
        A a = new A();
        for (int j = 0; j < 100; j++) {
            a.myrun();
        }
        try { Thread.sleep(2000); } catch(Exception e) {}
    }
    public void myrun() {
        int x = 0;
        for(int i=0;i<100000;i++) {
            C c = new C();
            synchronized(c) {
                Bees.process(c);
                x = c.bar()+1;
            }
        }
        System.out.println(x);
    }
}

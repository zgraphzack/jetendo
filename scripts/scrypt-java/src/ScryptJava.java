
import com.lambdaworks.crypto.SCryptUtil;
public class ScryptJava {

	/**
	 * @param args
	 */
	public static void main(String[] args) {

		int N = 65536; // CPU cost parameter. 11/10/2013 core i7-3740QM benchmark results: 16384 = 37ms,  32768 = 74ms, 65536 = 366ms, 131072 = 2.835ms
		int r = 16; // Memory cost parameter.
		int p = 1; // Parallelization parameter.  
		// scriptutil has 16 byte salt
		// scriptutil has default 256-bit key: dkLen = 32; // Intended length of the derived key.
		if(args[0].equals("encrypt")){
			if(args.length < 2){
				System.out.print("");
			}
			try{
				System.out.print(SCryptUtil.scrypt(args[1], N, r, p));
			}catch(Exception e){
				System.out.print("");
			}
		}else{
			if(args.length < 3){
				System.out.print("0");
			}
			try{
				boolean a=SCryptUtil.check(args[1], args[2]);
				if(a){
					System.out.print("1");
				}else{
					System.out.print("0");
				}
			}catch(Exception e){
				System.out.print("0");
			}
		}
	}

}

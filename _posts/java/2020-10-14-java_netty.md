
http://www.mamicode.com/info-detail-651145.html
当然一些框架可能会对socket进行一层封装，让其成为线程安全的。。。例如java的netty框架就是如此，将socket封装成channel，然后让channel封闭到一个线程中，那么这个channel的所有的读写都在它所在的线程中串行的进行，那么自然也就是线程安全的了

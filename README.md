# welcome
 ![menu.png](menu.png)
<div dir="rtl">
<h2>
	اسکریپت ری استارت کردن پنل مرزبان بصورت اتوماتیک
</h2>

 کد اجرای دستور در کامند لینوکس :
</div>

   ```
    bash <(curl -fsSL https://raw.githubusercontent.com/nsa14/script-reboot-marzban-automatically/master/install.sh)
   ```
   <br>
   <br>
   
<hr>

<div dir="rtl">
* سیستم عامل پیشنهادی : ubuntu 22

  *  حتما سرور درسترسی  روت (root) داشته باشد

<hr>
 * حتما درابتدا سرور خود را با دستور زیر آپدیت و اپگرید و در انتها آنرا ریبوت نمایید و سپس اقدام به اجرای اسکریپت نمایید

   ```sh
      apt update && apt upgrade -y
      sudo reboot
   ```



### روش اجرا :
** اسکریپت شامل منو می باشد که نحوه عملکرد هرکدام مشخص می باشد و نیازی به توضیح نیست. مثلا برای اجرای اسکریپت خودکار 
ریستارت شدن پنل کزینه ۱ را بزنید و در ادامه :
>1 -  اسکریپت 4 مرحله اجرا دارد که همه مراحل آن بصورت خودکار تنظیمات را انجام میدهد.

>2 -  در مرحله 3 شما باید زمان ریبوت شدن مرزبان را بر حسب ساعت وارد نمایید مثلا: 1
ک نشان دهنده ریبوت شدن مرزبان  در هر 1 ساعت می باشد

>4 -  پس از اجرای مرحله 4 و نمایش پیغام FINISH ( عکس زیر)
> ![finished.png](finished.png)
عملیات به درستی تنظیم و ذخیره شده است و در زمان انتخابی شما بصورت اتوماتیک اقدام به 
 ریستارت کردن پنل مرزبان مینماید.
<br>
/پایان عملیات


</div>
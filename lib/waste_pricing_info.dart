import 'package:flutter/material.dart';
import 'package:trashtrack/styles.dart';

class WastePricingInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: white,
        backgroundColor: green,
        title: Text("Waste Pricing Information"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Overview"),
              _sectionContent(
                  "Our waste pricing system is designed to ensure fair, transparent, and efficient pricing based on the type and weight of the waste. The pricing is influenced by the amount (kg) of waste disposed of, the category/type of waste, and the appropriate disposal or recycling method."),
              _sectionTitle("1. Key Factors Influencing Waste Pricing"),
              _sectionSubTitle("1.1 Waste Weight (Kg)"),
              _sectionContent(
                  "The primary factor influencing waste pricing is the weight of the waste being disposed of or recycled. Since waste disposal and recycling costs are generally calculated per kilogram, it is important to understand that the more waste you have, the higher the fee."),
              _sectionSubTitle("1.2 Type of Waste"),
              _sectionContent(
                  "The type of waste plays a significant role in determining the price. Different waste categories come with different disposal methods and processing requirements."),
              _sectionTitle("2. Relevant Laws and Regulations"),
              _sectionSubTitle("2.1 Republic Act No. 9003 (Ecological Solid Waste Management Act of 2000)"),
              _sectionContent(
                  "Republic Act No. 9003, also known as the Ecological Solid Waste Management Act of 2000, is the primary law that governs waste management in the Philippines, including Cebu. The Act mandates proper waste management practices, including segregation, recycling, and environmentally responsible disposal."),
              _sectionSubTitle("2.2 Local Ordinances and Policies in Cebu"),
              _sectionContent(
                  "In Cebu, each municipality or city follows the Republic Act No. 9003 but also has its own specific ordinances regarding waste collection fees. These ordinances are based on the waste management plans developed by the respective LGUs."),
              _sectionTitle("3. Waste Pricing Structure"),
              _sectionSubTitle("3.1 Biodegradable Waste (Compostable)"),
              _sectionContent(
                  "Price Range: PHP 1–3 per kilogram. Biodegradable waste like food scraps or garden waste is composted, which is a more sustainable and cost-effective disposal method."),
              _sectionSubTitle("3.2 Non-Biodegradable Waste (Landfill/Incineration)"),
              _sectionContent(
                  "Price Range: PHP 2–5 per kilogram. Non-biodegradable waste requires more expensive disposal methods, such as landfilling or incineration."),
              _sectionSubTitle("3.3 Recyclable Waste"),
              _sectionContent(
                  "Price Range: PHP 5–15 per kilogram (depending on market conditions). Recyclable materials like metals, plastics, and glass are more expensive to process and sort."),
              _sectionSubTitle("3.4 Hazardous Waste"),
              _sectionContent(
                  "Price Range: PHP 20+/kg Hazardous materials need strict handling, storage, and disposal measures as regulated by the Department of Environment and Natural Resources (DENR)."),
              _sectionTitle("4. Why Waste Pricing is Important"),
              _sectionContent(
                  "The pricing for waste disposal is integral to ensuring the sustainability of waste management programs. By charging based on weight and type of waste, we encourage responsible waste generation and disposal practices."),
              _sectionTitle("5. How Our Pricing System Benefits You"),
              _sectionContent(
                  "Our waste pricing system is designed to: \n- Encourage Recycling \n- Fair and Transparent \n- Compliant with the Law"),
              _sectionTitle("Conclusion"),
              _sectionContent(
                  "Our pricing is based on the weight of the waste and the type of waste material, ensuring that customers are charged fairly for the waste they generate. By strictly following the guidelines of Republic Act No. 9003, we aim to create a transparent, efficient, and environmentally responsible waste management system that benefits both customers and the environment."),
              SizedBox(height: 30),
              _sectionContent(
                  "For more detailed information, please refer to the full documentation of the following: Republic Act No. 9003, local Cebu ordinances, and additional resources: \n\n- [Republic Act No. 9003](https://www.officialgazette.gov.ph/2001/01/26/republic-act-no-9003/), \n- [NSWMC Price of Recyclables](https://nswmc.emb.gov.ph/wp-content/uploads/2016/08/Price-of-Recyclables.pdf), and \n- [DENR Solid Waste Management Data](https://emb.gov.ph/solid-waste-management-data)."),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: deepPurple),
      ),
    );
  }

  Widget _sectionSubTitle(String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        subtitle,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _sectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        content,
        style: TextStyle(fontSize: 14, height: 1.5),
      ),
    );
  }
}

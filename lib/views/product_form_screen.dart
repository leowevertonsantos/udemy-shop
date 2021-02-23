import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/providers/products.provider.dart';
import 'package:shop/widgets/app_drawer.dart';

class ProductFormScreen extends StatefulWidget {
  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _priceFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _imageURLFocus = FocusNode();
  final TextEditingController _imageUrlController = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final Map<String, Object> _formData = Map<String, Object>();

  bool isLoading = false;

  void _updateShowImage() {
    if (isValidImageURL(_imageUrlController.text)) {
      setState(() {});
    }
  }

  bool isValidImageURL(String url) {
    bool isValidProtocol = url.toLowerCase().startsWith('http://') ||
        url.toLowerCase().startsWith('https://');

    bool endsWithPNG = url.toLowerCase().endsWith('.png');
    bool endsWithJPG = url.toLowerCase().endsWith('.jpg');
    bool endsWithJPGE = url.toLowerCase().endsWith('.jpeg');

    return isValidProtocol && (endsWithPNG || endsWithJPG || endsWithJPGE);
  }

  @override
  void initState() {
    super.initState();
    _imageURLFocus.addListener(_updateShowImage);
  }

  @override
  void dispose() {
    super.dispose();
    _imageURLFocus.removeListener(_updateShowImage);
    _imageURLFocus.dispose();
    _priceFocus.dispose();
    _descriptionFocus.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final Product product =
        ModalRoute.of(context).settings.arguments as Product;

    if (product != null) {
      _formData['id'] = product.id;
      _formData['title'] = product.title;
      _formData['description'] = product.description;
      _formData['price'] = product.price;
      _formData['url'] = product.imageUrl;

      _imageUrlController.text = _formData['url'];
    }
  }

  void _saveForm() async {
    bool isValid = _form.currentState.validate();

    if (!isValid) {
      return;
    }
    _form.currentState.save();

    final Product product = new Product(
      id: _formData['id'],
      title: _formData['title'],
      imageUrl: _formData['url'],
      price: _formData['price'],
      description: _formData['description'],
    );

    setState(() {
      isLoading = true;
    });

    final ProductsProvider productsProvider =
        Provider.of<ProductsProvider>(context, listen: false);

    try {
      if (_formData['id'] == null) {
        await productsProvider.addProduct(product);
      } else {
        await productsProvider.updaeProduct(product);
      }

      Navigator.of(context).pop();
    } catch (e) {
      showDialog<Null>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text('Ocorreu um erro!'),
            content: Text('Ocorreu um erro ao salvar o produto!'),
            actions: [
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _formData['id'] != null
            ? Text('Editar Produto')
            : Text('Cadastrar Produto'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () => _saveForm(),
          )
        ],
      ),
      // drawer: AppDrawer(),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _formData['title'],
                      decoration: InputDecoration(labelText: 'Titulo'),
                      textInputAction: TextInputAction.next,
                      focusNode: _titleFocus,
                      onFieldSubmitted: (value) =>
                          FocusScope.of(context).requestFocus(_priceFocus),
                      onSaved: (newValue) => _formData['title'] = newValue,
                      validator: (value) {
                        if (value.trim().isEmpty) {
                          return 'Informe um titulo válido';
                        } else if (value.trim().length < 3) {
                          return 'Informe um titulo com no minimo 3 letras';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _formData['price'] != null
                          ? _formData['price'].toString()
                          : '',
                      decoration: InputDecoration(labelText: 'Preço'),
                      textInputAction: TextInputAction.next,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      focusNode: _priceFocus,
                      onFieldSubmitted: (value) => FocusScope.of(context)
                          .requestFocus(_descriptionFocus),
                      onSaved: (newValue) =>
                          _formData['price'] = double.parse(newValue),
                      validator: (value) {
                        if (value.trim().isEmpty) {
                          return 'Informe um Preço válido';
                        } else if (double.tryParse(value) == null ||
                            double.tryParse(value) <= 0) {
                          return 'Informe um Preço maior que 0.00';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _formData['description'],
                      decoration: InputDecoration(labelText: 'Descrição'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocus,
                      onSaved: (newValue) =>
                          _formData['description'] = newValue,
                      maxLength: 100,
                      validator: (value) {
                        if (value.trim().isEmpty) {
                          return 'Informe uma Descrição válida';
                        } else if (value.trim().length < 10) {
                          return 'Informe uma Descrição com no minimo 10 letras';
                        }

                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _imageUrlController,
                            decoration:
                                InputDecoration(labelText: 'URL da imagem'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            focusNode: _imageURLFocus,
                            onFieldSubmitted: (value) {
                              _saveForm();
                            },
                            onSaved: (newValue) => _formData['url'] = newValue,
                            validator: (value) {
                              if (value.trim().isEmpty ||
                                  !isValidImageURL(value)) {
                                return 'Informe uma URL válida';
                              }

                              return null;
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 8, left: 10),
                          height: 100,
                          width: 100,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          )),
                          child: _imageUrlController.text.isEmpty
                              ? Text('Informe a URL')
                              : Image.network(
                                  _imageUrlController.text,
                                  fit: BoxFit.cover,
                                ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
